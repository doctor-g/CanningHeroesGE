extends AudioStreamPlayer2D

func play_song(song:AudioStreamOGGVorbis)->void:
	stream = song
	play()
