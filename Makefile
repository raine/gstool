# PATH=$(npm bin):$PATH coffee
# PATH := ./node_modules/.bin:${PATH}

.PHONY : init clean build dist publish

init:
	npm install

clean:
	rm -rf lib/

build:
	./node_modules/.bin/coffee -o lib/ -c src/

dist: clean init build

publish: dist
	npm publish
