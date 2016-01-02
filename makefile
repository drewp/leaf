all: leaf-report.html leaf-report.js leaf-meter.js leaf-polling.js leaf-predict.js

%.html: %.jade
	jade < $< > $@ || rm $@
%.js: %.coffee
	coffee -c $<
loop:
	make all
	bin/watchmedo shell-command -c "make all"
