class User
	constructor: (@client, data) ->
		@profile = data

	getPlaylists: (cb) ->
		if @playlists
			cb null, @playlists
		else
			@client.request 'userGetPlaylists', userID: @profile.userID, (err, res) ->
				@playlists = res unless err
				cb err, res

	createPlaylist: (name, description='', songs=[], cb) ->
		@client.request 'createPlaylist',
			playlistName: name
			playlistAbout: description
			songIDs: songs
		, (err, playlistId) ->
			cb err, playlistId

module.exports = User
