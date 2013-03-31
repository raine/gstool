uuid   = require 'node-uuid'
crypto = require 'crypto'
http   = require 'request'
_      = require 'underscore'

class Client
	BASE_URL = 'https://grooveshark.com/more.php?'

	constructor: (arg) ->
		if typeof arg is 'string'
			@sessionId = arg

		@uuid = uuid.v4()

	getSession: (cb) ->
		http.get 'http://grooveshark.com', (err, resp, body) =>
			unless err
				@sessionId = resp.headers['set-cookie'].toString().match(/PHPSESSID=([^;]*)/)[1]
				if m = body.match /window.gsConfig = (\{.*?\});/
					@config = JSON.parse m[1]

				cb()
			else
				cb err

	getCommToken: (cb) ->
		@request 'getCommunicationToken', { secretKey: @createSecretKey() }, (err, res) =>
			unless err
				@commToken = res
				cb()
			else
				console.log "ERROR: #{err}" if @debug
				cb err

	createSecretKey: ->
		m = crypto.createHash 'md5'
		m.update @sessionId
		m.digest 'hex'

	createToken: (method) ->
		rand = crypto.pseudoRandomBytes(3).toString 'hex'
		pwd  = 'greenPlants'
		pass = "#{method}:#{@commToken}:#{pwd}:#{rand}"
		hash = crypto.createHash 'sha1'
		hash.update pass

		"#{rand}#{hash.digest 'hex'}"

	request: (method, params, cb) ->
		args = arguments
		logParams = _.clone params
		logParams.password = "***" if logParams.password
		console.log "[request] method: #{method} params: #{JSON.stringify logParams}" if @debug

		if not @sessionId?
			return @getSession =>
				@request.apply(this, args)

		if not @commToken? and method isnt 'getCommunicationToken'
			console.log 'No communication token, getting it' if @debug
			return @getCommToken =>
				@request.apply(this, args)

		body =
			method: method
			parameters: params
			header:
				client: 'htmlshark'
				clientRevision: '20120830'
				country: @config.country if @config
				privacy: 0
				session: @sessionId
				uuid: @uuid

		if method isnt 'getCommunicationToken'
			body.header.token = @createToken method

		http
			method: 'POST'
			uri: BASE_URL + method
			json: body
		, (err, resp, body) ->
			return cb err if err

			if body and body.fault
				cb body.fault.message
			else if body and body.result?
				cb null, body.result
			else
				cb error: 'something went wrong', res: resp

	login: (username, password, cb) ->
		@request 'authenticateUser',
			username: username
			password: password
		, (err, res) =>
			if not err and res.userID > 0
				console.log 'Logged in successfully' if @debug
				cb null, new (require './user') this, res
			else
				cb 'login failed'

	searchSongs: (query, cb) ->
		@request 'getResultsFromSearch',
			type: 'Songs'
			query: query
			guts: 0
			ppOverride: false
		, (err, res) ->
			unless err
				cb null, res.result
			else
				cb err

module.exports = Client
