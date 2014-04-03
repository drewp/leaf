#!bin/python
import sys, datetime, json
sys.path.append('pycarwings-master')
from connection import Connection
from userservice import UserService
from vehicleservice import VehicleService
from rdflib import Graph, Namespace
from dateutil.tz import tzlocal, tzutc
from twisted.internet import reactor
from twisted.python import log as twlog
import cyclone.web
import pymongo
NS = Namespace('http://bigasterisk.com/carwings/')

config = Graph()
config.parse('priv.n3', format='n3')

class Poller(object):
    def __init__(self, config, car, mongoColl):
        self.config, self.car = config, car
        self.mongoColl = mongoColl
    
    def readCarStatus(self):
        c = Connection(self.config.value(self.car, NS['username']),
                       self.config.value(self.car, NS['password']))
        u = UserService(c)
        d = u.login_and_get_status()
        if not c.logged_in:
            raise ValueError('login failed')

        result = {}

        result['vin'] = d.user_info.vin
        result['nickname'] = d.user_info.nickname
        v = VehicleService(c)
        v.request_status(result['vin'])
        d = u.get_latest_status(result['vin'])
        status = d.latest_battery_status
        result['notification_date_and_time'] = status.notification_date_and_time
        result.update(status.__dict__)
        # cruising range is in meters
        result['data_time'] = datetime.datetime.now(tzlocal())
        for attr in ['time_required_to_full_L2', 'time_required_to_full']:
            if result[attr] is not None:
                result[attr] = result[attr].total_seconds()
        print result
        self.mongoColl.insert(result)

class Latest(cyclone.web.RequestHandler):
    def get(self):
        doc = self.settings.coll.find_one(sort=[('data_time', -1)])
        del doc['_id'] # no uri yet :(
        for timeAttr in ["data_time",
                         "last_battery_status_check_execution_time",
                         "operation_date_and_time",
                         "notification_date_and_time"]:
            doc[timeAttr] = doc[timeAttr].replace(tzinfo=tzutc()).astimezone(tzlocal()).isoformat()
        json.dump(doc, self)

coll = pymongo.Connection('bang', 27017)['leaf']['readings']
poller = Poller(config, NS['car'], coll)

## defertothread
poller.readCarStatus()

twlog.startLogging(sys.stderr)

if __name__ == '__main__':
    SFH = cyclone.web.StaticFileHandler
    reactor.listenTCP(9058, cyclone.web.Application(handlers=[
        (r'/(|leaf-report\.html|bower_components/.*)', SFH, {"path": ".", "default_filename": "index.html"}),
        (r'/latest', Latest),
        ], coll=coll, poller=poller, debug=True))
    reactor.run()
