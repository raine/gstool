Worker = require './worker'

class GSWorker
	constructor: (@client) ->
		@worker = new Worker
			debug: false
			duration_ms: 1000
			defer_for_ms: 1000
			max_jobs_per_duration: 1
			task: (query, cb) =>
				@client.searchSongs	query, (err, res) ->
					cb err, res?[0]

		@songs = []

	push: (query, cb) ->
		@worker.queue.push query, (err, res) =>
			if not err
				@songs.push res
				cb null, res
			else
				throw "ERROR: #{err}"

module.exports = GSWorker
