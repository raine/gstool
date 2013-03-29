fs          = require 'fs'
_           = require 'underscore'
ProgressBar = require 'progress'
async       = require 'async'

gs          = require './src/grooveshark/grooveshark'
Spotify     = require './src/spotify'
Tinysong    = require './src/tinysong'
prompt      = require './src/prompt'

fetchSongMetadata = (opts, done) ->
	tinysong = new Tinysong opts.tinysongKey
	spotify  = Spotify.getTracksFromIDs opts.tracks

	progress = new ProgressBar 'Fetching song metadata... [:bar] :percent :current/:total',
		total: opts.tracks.length
		width: 30

	spotify.on 'track', (track) ->
		tinysong.push "#{track.artists[0]} #{track.name}", (err, res) ->
			progress.tick()

			if tinysong.songs.length is opts.tracks.length
				songs = tinysong.songs.filter (e) -> e?
				console.log "\nDone! #{songs.length} of #{opts.tracks.length} tracks found on Grooveshark"
				done null, songs

prompt.setup (err, opts) ->
	throw "ERROR: #{err}" if err

	fetchSongMetadata opts, (err, songs) ->
		console.dir songs
