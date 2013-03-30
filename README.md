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