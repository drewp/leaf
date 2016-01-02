#!bin/python
from __future__ import division
import sys, datetime, json, logging, time, math
sys.path.append('pycarwings-master')
from connection import Connection
from userservice import UserService
from vehicleservice import VehicleService
from rdflib import Graph, Namespace
from dateutil.tz import tzlocal, tzutc
from twisted.internet import reactor, threads, task
from twisted.python import log as twlog
import cyclone.web
import pymongo
NS = Namespace('http://bigasterisk.com/carwings/')

log = logging.getLogger()
logging.basicConfig(level=logging.INFO)
config = Graph()
config.parse('priv.n3', format='n3')

def nowLocal():
    return datetime.datetime.now(tzlocal())
    
class Poller(object):
    def __init__(self, config, car, mongoColl):
        self.config, self.car = config, car
        self.mongoColl = mongoColl
    
    def readCarStatus(self):
        log.info("readCarStatus starts")
        c = Connection(self.config.value(self.car, NS['username']),
                       self.config.value(self.car, NS['password']))
        userService = UserService(c)
        log.info('login_and_get_status')
        status = userService.login_and_get_status(timeout=30)
        if not c.logged_in:
            raise ValueError('login failed')

        result = {}

        result['vin'] = status.user_info.vin
        result['nickname'] = status.user_info.nickname
        v = VehicleService(c)
        requestTime = nowLocal() - datetime.timedelta(seconds=2)
        log.info('request_status')
        v.request_status(result['vin'])
        tries = 0
        while True:
            tries += 1
            if tries > 60:
                log.info("giving up on this request")
                return
            self.updateWithLatestData(result, userService, result['vin'])
            log.info("try %s. request time was %s, "
                     "latest status operation time is %s",
                     tries, requestTime,
                     result['operation_date_and_time'].astimezone(tzlocal()))
            if result['operation_date_and_time'] > requestTime:
                break
            time.sleep(10)

        log.info("got a new result: %s", result)
        self.mongoColl.insert(result)

    def updateWithLatestData(self, result, userService, vin):
        d = userService.get_latest_status(vin)
        status = d.latest_battery_status
        result['notification_date_and_time'] = status.notification_date_and_time
        result.update(status.__dict__)
        # cruising range is in meters
        result['data_time'] = nowLocal()
        for attr in ['time_required_to_full_L2', 'time_required_to_full']:
            if result[attr] is not None:
                result[attr + '_sec'] = result[attr].total_seconds()
                del result[attr]
        # also fix stringified numbers

def toLocal(dt):
    return dt.replace(tzinfo=tzutc()).astimezone(tzlocal())
                
class Latest(cyclone.web.RequestHandler):
    def get(self, *args):
        docs = self.settings.coll.find(sort=[('data_time', -1)], limit=180)
        doc = docs[0]
        del doc['_id'] # no uri yet :(
        for timeAttr in ["data_time",
                         "last_battery_status_check_execution_time",
                         "operation_date_and_time",
                         "notification_date_and_time"]:
            doc[timeAttr] = toLocal(doc[timeAttr]).isoformat()

        doc['previous'] = [[toLocal(d['operation_date_and_time']).isoformat(),
                            d['battery_remaining_amount']]
                           for d in docs]
        doc['previous'].sort()
        doc['nextPollTime'] = nextPollTime(coll, nowLocal()).isoformat()
        json.dump(doc, self)


class LastUpdateCheck(cyclone.web.RequestHandler):
    def get(self, *args):
        latestDoc = self.settings.coll.find_one(sort=[('data_time', -1)])
        maxMinutesOld = 60
        if not latestDoc or (nowLocal() - toLocal(latestDoc['data_time'])).total_seconds() > (maxMinutesOld * 60):
            raise ValueError("latest check is too old")
        self.write('ok')
        

coll = pymongo.Connection('bang', 27017)['leaf']['readings']
poller = Poller(config, NS['car'], coll)

def lastPollTime(coll):
    doc = coll.find_one(sort=[('data_time', -1)])
    if not doc:
        return datetime.datetime(1900, 1, 1, tzinfo=tzlocal())
    return toLocal(doc['operation_date_and_time'])

dailyStartHour = 8
dailyEndHour = 21 # this should be adjusted if we're charging late
dailyEndHour = 24
periodHours = 1. / 3
def nextAfter(dt):
    dayStart = dt.replace(hour=0, minute=0, second=0, microsecond=0)
    offsetHours = (dt - dayStart).total_seconds() / 3600
    
    if offsetHours < dailyStartHour:
        return dayStart + datetime.timedelta(hours=dailyStartHour)
    if offsetHours > dailyEndHour:
        return dayStart + datetime.timedelta(days=1, hours=dailyStartHour)
    return dayStart + datetime.timedelta(
        hours=math.ceil(offsetHours / periodHours) * periodHours)
    
def nextPollTime(coll, now):
    lastTime = lastPollTime(coll)

    if nextAfter(lastTime) < now:
        return now

    return nextAfter(now)

def loop():
    def waitThenLoop(*args):
        reactor.callLater(30, loop)
    # also record if a req is going, and don't run a timed one during
    # a manual one.
    now = nowLocal()
    nextTime = nextPollTime(coll, now)
    log.info("waiting until %s" % nextTime)

    def go():
        d = threads.deferToThread(poller.readCarStatus)
        d.addCallbacks(waitThenLoop, waitThenLoop)
    reactor.callLater((nextTime - now).total_seconds(), go)
    
loop()


twlog.startLogging(sys.stderr)

if __name__ == '__main__':
    SFH = cyclone.web.StaticFileHandler
    reactor.listenTCP(9058, cyclone.web.Application(handlers=[
        (r'/(|leaf-.*?\.(?:html|js)|filters\.js|mockup\.svg|bower_components/.*)', SFH,
         {"path": ".", "default_filename": "index.html"}),
        (r'/(leaf/)?latest', Latest),
        (r'/lastUpdateCheck', LastUpdateCheck),
        ], coll=coll, poller=poller, debug=True))
    reactor.run()
