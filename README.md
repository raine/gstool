gstool
======

A command-line tool for moving Spotify playlists to Grooveshark.

An API key for Tinysong.com is required. You can get one
[here](http://www.tinysong.com/api) emailed to you instantly.

---

### Installation

	npm install -g gstool
	
### Example

	$ gstool -i songs.txt
	Enter Grooveshark username: raneksi
	Enter Grooveshark password:
	Read 566 track(s) from the file
	Enter a name for the playlist: my playlist
	Authenticated with Grooveshark successfully
	Fetching track metadata... [=============================] 100% 566/566
	Done! 493 of 566 tracks found on Grooveshark
	Created a new playlist with 493 tracks: http://grooveshark.com/#!/playlist/my+playlist/84837484

### Help

	Usage: gstool [options]

	Options:

	-h, --help                 output usage information
	-V, --version              output the version number
	-i, --input <file>         read spotify playlist from a file
	-u, --username <username>  grooveshark username
	-p, --password <password>  grooveshark password
	-k, --tinysong-key <key>   tinysong API key (tinysong.com/api)
	-l, --playlist <name>      name of the playlist
	-v, --verbose              verbose output

### Tinysong rate-limiting

Tinysong API is used to find Grooveshark equivalents for the tracks. As
it happens, Tinysong is pretty aggressive in its rate-limiting, allowing
around a few hundred calls per day. You can email support@grooveshark.com and
they will most likely increase the limit for your API key.

This is very inconvenient and if I learn about a workaround I will look into
it.
