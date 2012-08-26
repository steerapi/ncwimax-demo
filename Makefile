all: node-app.js ssh.js
	cd web; make

%.js: %.coffee
	coffee -cb $<

watch:
	watch -n 1 make

kill:
	killall node nodejs

run: all
	node node-app.js

forever: all
	forever start node-app.js

.PHONY: run watch