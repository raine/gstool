# PATH=$(npm bin):$PATH coffee
# PATH := ./node_modules/.bin:${PATH}

.PHONY : init clean build dist publish

init:
	npm install

clean:
	rm -rf lib/*.js

build:
	./node_modules/.bin/coffee -c lib/

dist: clean init build

publish: dist
	npm publish
