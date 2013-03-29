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

fatal = (err) ->
	console.log "ERROR: #{err}" if err
	process.exit (if err then 1 else 0)

async.waterfall [
	prompt.setup

	(opts, cb) ->
		client = new gs.Client 'c65a658cd043f0e1b4e44bfbf9433298' # TODO
		client.debug = false
		client.login opts.gsCreds.username, opts.gsCreds.password, (err, user) ->
			unless err
				console.log 'Authenticated with Grooveshark successfully'
				cb null, opts: opts, user: user
			else
				cb err

	# Check if playlist with the given name exists
	# NOTE: Grooveshark allows multiple playlists with the same name, but
	#       appending to an existing one is a useful feature.
	(params, cb) ->
		params.user.getPlaylists (err, playlists) ->
			return cb err if err

			if playlist = _.find(playlists, (e) -> e.name is params.opts.playlist)
				prompt.program.confirm """
				Playlist \"#{params.opts.playlist}\" exists, do you want to *delete* it and create a new one but and the old songs?
				Y: Delete and create a new playlist with the old songs
				N: Create a new playlist with the same name """, (ok) ->
					params.appendToPlaylist = ok
					params.playlist = playlist
					cb null, params
			else
				cb null, params

	# Get song metadata
	(params, cb) ->
		fetchSongMetadata params.opts, (err, songs) ->
			if songs.length > 0
				params.songs = songs
				cb null, params
			else
				cb 'No songs found'

	(params, cb) ->
		songIDs = params.songs.map (s) -> s.SongID

		createPlaylist = (name, ids) ->
			params.user.createPlaylist name, '', ids, (err, playlistId) ->
				return cb err if err

				console.log "Created a new playlist: #{gs.Playlist.getURL name, playlistId}"
				cb null, params

		if params.appendToPlaylist
			params.playlist.getSongs (err, songs) ->
				oldIDs      = songs.map (s) -> parseInt s.SongID
				combinedIDs = _.union oldIDs, songIDs

				params.playlist.delete (err, res) ->
					createPlaylist params.playlist.name, combinedIDs
		else
			createPlaylist params.opts.playlist, songIDs

], (err, params) ->
	fatal err if err
	process.exit()
