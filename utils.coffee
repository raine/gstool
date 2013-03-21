module.exports =
	debug: (obj) ->
		util = require 'util'
		fs   = require 'fs'
		exec = require('child_process').exec
		fs.writeFileSync 'debug.txt', util.inspect(obj)
		exec 'open debug.txt'
