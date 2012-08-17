all: node-app.js
	cd web; make

%.js: %.coffee
	coffee -cb $<

watch:
	watch -n 1 make

run: all
	forever start node-app.js

.PHONY: run watch