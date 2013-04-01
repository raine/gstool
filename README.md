gs-tool
========

A command-line tool for moving Spotify playlists to Grooveshark.

A brief how-to for the time being:

	git clone git://github.com/raneksi/gs-tool.git && cd gs-tool
	npm install
	./main.coffee -h
	
---
	
### Help

	Usage: main.coffee [options]

	Options:

    -h, --help                 output usage information
    -V, --version              output the version number
    -i, --input <file>         read spotify playlist from a file
    -u, --username <username>  grooveshark username
    -p, --password <password>  grooveshark password
    -k, --tinysong-key <key>   tinysong API key (tinysong.com/api)
    -l, --playlist <name>      name of the playlist
    -v, --verbose              verbose output

### Example

	gstool [master] % ./main.coffee
	Enter Grooveshark username: raneksi
	Enter Grooveshark password:
	Copy and paste tracks from spotify (enter an empty line after done):
	http://open.spotify.com/track/0KXekBrWxu4N64Ly8vGgRc
	http://open.spotify.com/track/19EQUqnUXEeiBrY10JhPEF
	…
	
	Read 566 track(s) from input
	Enter a name for the playlist: my playlist
	Authenticated with Grooveshark successfully
	Fetching track metadata... [=============================] 100% 566/566
	Done! 493 of 566 tracks found on Grooveshark
	Created a new playlist with 493 tracks: http://grooveshark.com/#!/playlist/my+playlist/84837484
