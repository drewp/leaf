all: leaf-report.html leaf-report.js leaf-meter.js

%.html: %.jade
	/usr/lib/node_modules/nodefront/node_modules/jade/bin/jade < $< > $@ || rm $@
%.js: %.coffee
	coffee -c $<
loop:
	make all
	bin/watchmedo shell-command -c "make all"
