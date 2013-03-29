_              = require 'underscore'
fs             = require 'fs'
spotify        = require 'spotify'
Worker         = require './worker'
{EventEmitter} = require 'events'

Spotify = ( ->
	parseTrack: (str) ->
		m[2] if m = str.match /.*?track(\/|:)([a-zA-Z0-9]{22})/

	parseTracksFromFile: (path) ->
		lines  = ((fs.readFileSync path, 'utf8').split "\n").slice(0, -1)
		_.compact lines.map (e) => @parseTrack e
	
	getTracksFromIDs: (ids, cb) ->
		emitter = new EventEmitter
		songs   = []

		lookup = (id, cb) ->
			spotify.lookup type: 'track', id: id, (err, res) ->
				if err
					console.log 'spotify lookup failed', err
					cb err # not handled in any way
				else
					obj =
						name: res.track.name
						artists: _.pluck res.track.artists, 'name'

					songs.push obj
					cb null, obj

		worker = new Worker
			debug: false
			duration_ms: 1000
			defer_for_ms: 1000
			max_jobs_per_duration: 10
			task: lookup

		worker.queue.push ids, (err, track) ->
			emitter.emit 'track', track

		worker.queue.drain = ->
			cb null, songs if cb

		emitter
)()

module.exports = Spotify
