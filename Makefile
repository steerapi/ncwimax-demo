all: node-app.js ssh.js
	cd web; make

%.js: %.coffee
	coffee -cb $<

watch:
	watch -n 1 make

run: all
	killall node nodejs & forever start node-app.js

.PHONY: run watch