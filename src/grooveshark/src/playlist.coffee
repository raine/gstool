class Playlist
	@getURL: (name, id) ->
		# This isn't exactly how Grooveshark does it but it's good enough and
		# the name in the URL doesn't matter anyway
		name = name
			.replace(/[^A-Za-z0-9 ]*/g, '') # Remove everything weird
			.replace(/\s{2,}/g, ' ')        # Trim more than two subsequent spaces
			.replace(/\s/g, '+')            # Replace spaces with +

		"http://grooveshark.com/#!/playlist/#{name}/#{id}"

	constructor: (@client, data) ->
		# Some values from data not added
		@UUID   = data.UUID
		@userID = data.UserID
		@id     = data.PlaylistID
		@name   = data.Name

	delete: (cb) ->
		@client.request 'deletePlaylist',
			playlistID: @id
			name: '' # This parameter doesn't seem to matter but has to be in the request
		, (err, res) ->
			cb err, res

	getSongs: (cb) ->
		@client.request 'playlistGetSongs', playlistID: @id, (err, res) =>
			return cb err if err
			@songs = res.Songs
			cb null, @songs

	getURL: ->
		Playlist.getURL @name, @id

module.exports = Playlist
