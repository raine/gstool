gstool
======

A command-line tool for moving Spotify playlists to Grooveshark.

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
