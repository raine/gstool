request = require 'request'

BASE_URL = 'http://tinysong.com/'

req = (method, query, opts={}, cb) ->
	if not module.exports.API_KEY
		throw """
	API_KEY not set
	tinysong.API_KEY = 'your_api_key' # Get yours at http://tinysong.com/api
	"""
		return cb 'API_KEY not set'

	request.get
		uri: "http://tinysong.com/#{method}/#{query}"
		json: true
		qs:
			format: 'json'
			key: module.exports.API_KEY
			limit: opts.limit if opts.limit?
		, (err, resp, json) ->
			if err or json.error?
				cb (err or json.error)
			else
				cb null, json

module.exports =
	API_KEY: ''

	a: (query, cb) ->
		req 'a', query, {}, (err, res) -> cb err, res

	b: (query, cb) ->
		req 'b', query, {}, (err, res) -> cb err, res

	s: (query, limit, cb) ->
		if typeof limit is 'function'
			cb    = limit
			limit = 5

		req 's', query, limit: limit, (err, res) ->
			cb err, res
