fs          = require 'fs'
gs          = require './src/grooveshark/grooveshark'
Spotify     = require './src/spotify'
Tinysong    = require './src/tinysong'
_           = require 'underscore'
ProgressBar = require 'progress'
async = require 'async'

program = require 'commander'
program.version '0.0.1'
program.option '-i, --input <file>', 'Read spotify playlist from a file'
program.option '-u, --username <username>', 'Grooveshark username'
program.option '-p, --password <password>', 'Grooveshark password'
program.option '-k, --tinysong-key <key>', 'Tinysong API key (tinysong.com/api)'
program.option '-l, --playlist <name>', 'Name of the playlist'

program.on '--help', ->
	# TODO

program.parse process.argv

askTinysongKey = (cb) ->
	program.prompt 'Enter Tinysong API key: ', (input) ->
		cb null, input

askCredentials = (cb) ->
	s = 'Enter Grooveshark'

	async.series [
		(cb) -> program.prompt   "#{s} username: ", (input) -> cb null, input
		(cb) -> program.password "#{s} password: ", (input) -> cb null, input
	], (err, result) ->
		cb null, username: result[0], password: result[1]

askTracks = (cb) ->
	program.prompt 'Copy and paste tracks from spotify (enter an empty line after done):', (input) ->
		tracks = _.compact input.split("\n").map (e) -> Spotify.parseTrack e
		cb null, tracks

askPlaylist = (cb) ->
	program.prompt 'Enter a name for the playlist: ', (input) ->
		cb null, input

async.series
	tinysongKey: (cb) ->
		if program.tinysongKey
			cb null, program.tinysongKey
		else
			askTinysongKey cb

	gsCreds: (cb) ->
		if program.username and program.password
			cb null, username: program.username, password: program.password
		else
			askCredentials cb

	tracks: (cb) ->
		if program.input
			# TODO: could use some error handling and a callback
			tracks = Spotify.parseTracksFromFile program.input

			if tracks.length > 0
				console.log "Read #{tracks.length} track(s) from the file"
				cb null, tracks
			else
				cb 'No tracks in file'
		else
			askTracks (err, tracks) ->
				if tracks.length > 0
					console.log "Read #{tracks.length} track(s) from input"
					cb null, tracks
				else
					console.log 'Unable to find tracks in the input'
					cb 'No tracks in input'

	playlist: (cb) ->
		if program.playlist
			cb null, program.playlist
		else
			askPlaylist cb

, (err, opts) ->
	return console.log "ERROR: #{err}" if err

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

	fetchSongMetadata opts, (err, songs) ->
		console.dir songs
