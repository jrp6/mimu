mimu
====

Web app that makes the computer running the app play youtube videos in the background

Specs
-----

* When GETing /watch?v=:ytid, add video :id to the end of the playlist. (This is _ugly_ and _unRESTful_ but I can't come up with a practical and easy way to make this work using any other method)
* /playlist (redirect from /) is an HTML table representation of the playlist, along with buttons to
  * Delete any video from the playlist,
  * Play, and
  * Pause
* /playlist/:id removes :id from the playlist, when DELETEd
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
		* getQueueLength (return playlist length, i.e. the largest array index + 1)
		* getYtid (int: get the ytid that corresponds with the specified index)
	  * Signals:
		* nowPlaying (string: ytid that has started playing)
		* statusPlaying (bool: the status has changed to playing/stopped (true/false)
		* errorOccurred (string: error description)
* Dependencies:
  * Sinatra
  * Slim
  * ruby-dbus
  
