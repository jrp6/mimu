mimu
====

Web app that makes the computer running the app play youtube videos in the background

To run
------
Run ./mimud.rb and ./frontend -e production, preferably within tmux/screen

TODO
----
* Implement deletion
* Add a way for the web frontend to know whether the backend is playing
* Emit signals when they should be (Trivial except for errorOccurred)
* Stop playing instantly when status changes to paused (currently plays current video to the end)

Specs
-----

* When GETing /watch?v=:ytid, ask the user whether to add video :ytid to the end of the playlist.
* /playlist (redirect from /) is an HTML table representation of the playlist, along with buttons to
  * Delete any video from the playlist,
  * Play, and
  * Pause
* /playlist/:id removes :id from the playlist when DELETEd
* /play-pause, depending on method:
  * GET: "playing" if playing, "paused" if paused
  * POST: start playing if "play", pause if "pause"
* Playlist, kept in backend memory
  * ytid
  * Keep track of current array index
  * When /play-pause is set to "playing" and playlist has an unplayed video, start playing it (using youtube-dl and mplayer/vlc)
  * When the player stops, increment index and go to the previous step
* Communication between the front- and the backend
  * D-Bus (on the session bus) (NB! If you want to use the system bus, you must configure it yourself)
	* Service fi.ouka.edu.lyseo.mimu
	* Interface fi.ouka.edu.lyseo.mimu.playlist
	  * Methods:
		* play (bool: start playing if true, stop if false)
		* queue (string: add specified ytid to end of the playlist)
		* unqueue (int: index to remove from playlist)
		* getQueueLength (returns int: playlist length, i.e. the largest array index + 1)
		* getYtid (int: get the ytid that corresponds with the specified index)
		* getStatus (return bool: status, ie. whether mimu is playing or stopped (true or false))
	  * Signals:
		* nowPlaying (string: ytid that has started playing)
		* statusChanged (bool: the status has changed to playing/stopped (true/false)
		* errorOccurred (string: error description)
* Dependencies:
  * Sinatra
  * Slim
  * ruby-dbus
  * VLC
  * video_info
  
