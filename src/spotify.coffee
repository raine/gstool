_       = require 'underscore'
spotify = require 'spotify'
Worker  = require './worker'

Spotify = ( ->
	parseURIfromURL: (url) ->
		if match = url.match /.*\/(track|album|artist)\/(.*)$/
			{ type: match[1], id: match[2] }

	getSongsFromURLs: (urls, cb) ->
		ids = urls.map (url) => @parseURIfromURL url
		@getSongsFromIDs ids, cb
	
	getSongsFromIDs: (ids, cb) ->
		songs = []

		lookup = (sObj, cb) ->
			spotify.lookup type: sObj.type, id: sObj.id, (err, res) ->
				if err
					console.log 'spotify lookup failed', err
					cb err # not handled in any way
				else
					songs.push
						track: res.track.name
						artists: _.pluck res.track.artists, 'name'

					cb null

		worker = new Worker
			debug: false
			duration_ms: 1000
			defer_for_ms: 1000
			max_jobs_per_duration: 1
			task: lookup

		worker.queue.push ids
		worker.queue.drain = ->
			cb null, songs
)()

module.exports = Spotify
