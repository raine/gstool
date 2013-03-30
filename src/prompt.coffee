async   = require 'async'
program = require 'commander'
_       = require 'underscore'

Spotify = require './spotify'

program.version '0.0.1'
program.option '-i, --input <file>', 'read spotify playlist from a file'
program.option '-u, --username <username>', 'grooveshark username'
program.option '-p, --password <password>', 'grooveshark password'
program.option '-k, --tinysong-key <key>', 'tinysong API key (tinysong.com/api)'
program.option '-l, --playlist <name>', 'name of the playlist'
program.option '-v, --verbose', 'verbose output'
program.parse process.argv

askTinysongKey = (cb) ->
	program.prompt 'Enter Tinysong API key: ', (input) ->
		cb null, input

s = 'Enter Grooveshark'

askUsername = (cb) ->
	program.prompt "#{s} username: ", (input) -> cb null, input

askPassword = (cb) ->
	program.password "#{s} password: ", (input) -> cb null, input

askTracks = (cb) ->
	program.prompt 'Copy and paste tracks from spotify (enter an empty line after done):', (input) ->
		tracks = _.compact input.split("\n").map (e) -> Spotify.parseTrack e
		cb null, tracks

askPlaylist = (cb) ->
	program.prompt 'Enter a name for the playlist: ', (input) ->
		cb null, input
	
exports.setup = (done) ->
	async.series
		tinysongKey: (cb) ->
			if program.tinysongKey
				cb null, program.tinysongKey
			else
				askTinysongKey cb

		username: (cb) ->
			if program.username
				cb null, program.username
			else
				askUsername cb

		password: (cb) ->
			if typeof program.password is 'string'
				cb null, program.password
			else
				askPassword cb

		tracks: (cb) ->
			if program.input
				tracks = Spotify.parseTracksFromFile program.input
				cb 'File does not exist' unless tracks

				if tracks.length > 0
					console.log "Read #{tracks.length} track(s) from the file"
					cb null, tracks
				else
					cb 'No tracks in the file'
			else
				askTracks (err, tracks) ->
					if tracks.length > 0
						console.log "Read #{tracks.length} track(s) from input"
						cb null, tracks
					else
						cb 'No tracks in the input'

		playlist: (cb) ->
			if program.playlist
				cb null, program.playlist
			else
				askPlaylist cb

	, (err, opts) ->
		done err, opts

exports.program = program
