all: leaf-report.html leaf-report.js leaf-meter.js leaf-polling.js leaf-predict.js

%.html: %.jade
	/usr/lib/node_modules/nodefront/node_modules/jade/bin/jade.js < $< > $@ || rm $@
%.js: %.coffee
	coffee -c $<
loop:
	make all
	bin/watchmedo shell-command -c "make all"
