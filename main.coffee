#!/usr/bin/env coffee

_           = require 'underscore'
ProgressBar = require 'progress'
async       = require 'async'
gs          = require 'gs-more'

Spotify     = require './src/spotify'
Tinysong    = require './src/tinysong'
prompt      = require './src/prompt'

fetchSongMetadata = (opts, done) ->
	tinysong = new Tinysong opts.tinysongKey
	spotify  = Spotify.getTracksFromIDs opts.tracks

	progress = new ProgressBar 'Fetching track metadata... [:bar] :percent :current/:total',
		total: opts.tracks.length
		width: 30

	spotify.on 'track', (track) ->
		tinysong.push "#{track.artists[0]} #{track.name}", (err, res) ->
			progress.tick()

			if tinysong.songs.length is opts.tracks.length
				songs = _.compact tinysong.songs
				console.log "\nDone! #{songs.length} of #{opts.tracks.length} tracks found on Grooveshark"
				done null, songs

async.waterfall [
	prompt.setup

	(opts, cb) ->
		client = new gs.Client # TODO: Initialize with old sessionId
		client.debug = true if prompt.program.verbose
		client.login opts.username, opts.password, (err, user) ->
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
				Playlist \"#{params.opts.playlist}\" exists, do you want to *delete* it and create a new one with the old tracks?
				Y: Delete and create a new playlist with the old tracks (a bit like append)
				N: Create a new playlist with the same name -- """, (ok) ->
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
				cb 'No tracks found'

	(params, cb) ->
		songIDs = params.songs.map (s) -> s.SongID

		createPlaylist = (name, ids) ->
			params.user.createPlaylist name, '', ids, (err, playlistId) ->
				return cb err if err

				console.log "Created a new playlist with #{ids.length} tracks: #{gs.Playlist.getURL name, playlistId}"
				cb null, params

		if params.appendToPlaylist
			params.playlist.getSongs (err, songs) ->
				oldIDs      = songs.map (s) -> s.SongID
				combinedIDs = _.union oldIDs, songIDs

				params.playlist.delete (err, res) ->
					createPlaylist params.playlist.name, combinedIDs
		else
			createPlaylist params.opts.playlist, songIDs

], (err, params) ->
	console.log "ERROR: #{err}" if err
	process.exit (if err then 1 else 0)
