extends AudioStreamPlayer2D

export(float) var sound_duration = 9.5

func _on_Game_round_started(game:Game):
	var time_until_ticking = game.round_duration - sound_duration
	# If we're playing a very short round (e.g. warp speed for testing),
	# then do not bother with the timer.
	if time_until_ticking > 0:
		$Timer.start(time_until_ticking)


# When the timer goes off, start the ticking sound
func _on_Timer_timeout():
	play()
