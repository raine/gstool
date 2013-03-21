uuid   = require 'node-uuid'
crypto = require 'crypto'
utils  = require './utils'
http   = require 'request'

class Grooveshark
	BASE_URL = 'https://grooveshark.com/more.php?'

	constructor: (arg) ->
		if typeof arg is 'string'
			@sessionId = arg

	getSession: (cb) ->
		http.get 'http://grooveshark.com', (err, resp, body) =>
			unless err
				@sessionId = resp.headers['set-cookie'].toString().match(/PHPSESSID=([^;]*)/)[1]
				cb()
			else
				cb err

	getCommToken: (cb) ->
		@request 'getCommunicationToken', { secretKey: @createSecretKey() }, (err, res) =>
			unless err
				@commToken = res
				cb()
			else
				console.log "error: #{err}"
				cb err

	createSecretKey: ->
		m = crypto.createHash 'md5'
		m.update @sessionId
		m.digest 'hex'

	createToken: (method) ->
		rand = crypto.pseudoRandomBytes(3).toString 'hex'
		pwd  = 'breakfastBurritos'
		pass = "#{method}:#{@commToken}:#{pwd}:#{rand}"
		hash = crypto.createHash 'sha1'
		hash.update pass

		"#{rand}#{hash.digest 'hex'}"

	request: (method, params, cb) ->
		args = arguments
		console.log "[request] method: #{method} params: #{JSON.stringify params}"

		if not @sessionId?
			return @getSession =>
				@request.apply(this, args)

		if not @commToken? and method isnt 'getCommunicationToken'
			console.log 'no communication token, getting it'
			return @getCommToken =>
				@request.apply(this, args)

		body =
			method: method
			parameters: params
			header:
				client: 'htmlshark'
				clientRevision: '20120312'
				country: 'FI' # TODO
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
			else if body and body.result
				cb null, body.result
			else
				cb error: 'something went wrong', res: resp

	login: (username, password, cb) ->
		md5 = (str) ->
			h = crypto.createHash 'md5'
			h.update str
			h.digest 'hex'

		@request 'authenticateUser',
			username: username
			password: md5 password
		, (err, res) ->
			if not err
				console.log 'logged in successfully'
				cb null, res

client = new Grooveshark 'c65a658cd043f0e1b4e44bfbf9433298'
client.request 'userGetPlaylists', { userID: 486348 }, (err, res) ->
	console.dir err
	console.dir res

client.login 'raneksi', '***REMOVED***', (err, res) ->
	console.dir res
