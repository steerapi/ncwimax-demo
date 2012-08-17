all: node-app.js
	cd web; make

%.js: %.coffee
	coffee -cb $<

watch:
	watch -n 1 make

run: all
	killall nodejs
	forever start node-app.js

.PHONY: run watch