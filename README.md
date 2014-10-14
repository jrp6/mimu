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
* Playlist, kept in memory (sqlite?)
  * Rows: id, title (fetch using youtube API), ytid
  * Keep track of current id
  * When /play-pause is set to "playing" and playlist has an id the same as current id, start playing it (using youtube-dl and mplayer/vlc)
  * When the player stops, increment current id and go to the previous step
