Worker   = require './worker'
tinysong = require 'tinysong'

class TinysongWorker
	constructor: (apiKey) ->
		tinysong.API_KEY = apiKey

		@worker = new Worker
			debug: false
			duration_ms: 1000
			defer_for_ms: 1000
			max_jobs_per_duration: 5
			task: @lookup

		@songs = []
	
	lookup: (query, cb) ->
		tinysong.b query, (err, res) =>
			cb err, res

	push: (query, cb) ->
		@worker.queue.push query, (err, res) =>
			if not err
				@songs.push res
			else
				throw "Tinysong ERROR: #{err}"

			cb err, res

module.exports = TinysongWorker
