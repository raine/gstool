_              = require 'underscore'
fs             = require 'fs'
spotify        = require 'spotify'
Worker         = require './worker'
{EventEmitter} = require 'events'

Spotify = ( ->
	parseTrack: (str) ->
		m[2] if m = str.match /.*?track(\/|:)([a-zA-Z0-9]{22})/

	parseTracksFromFile: (path) ->
		if fs.existsSync path
			lines  = ((fs.readFileSync path, 'utf8').split "\n").slice(0, -1)
			_.compact lines.map (e) => @parseTrack e
	
	getTracksFromIDs: (ids) ->
		emitter = new EventEmitter

		lookup = (id, cb) ->
			spotify.lookup type: 'track', id: id, (err, res) ->
				if err
					cb err
				else
					cb null,
						name: res.track.name
						artists: _.pluck res.track.artists, 'name'

		worker = new Worker
			debug: false
			duration_ms: 1000
			defer_for_ms: 1000
			max_jobs_per_duration: 1
			task: lookup

		worker.queue.push ids, (err, track) ->
			if err
				# TODO: should it recover from a failed request? perhaps by skipping the track
				console.log err
				throw "ERROR: Request to Spotify failed"
			else
				emitter.emit 'track', track

		emitter
)()

module.exports = Spotify
