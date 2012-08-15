all:
	cd web; make
watch:
	watch -n 1 make
run: all
	coffee node-app.coffee
.PHONY: run watch