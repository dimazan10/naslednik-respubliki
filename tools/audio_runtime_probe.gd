extends SceneTree


func _initialize() -> void:
	call_deferred("run_probe")


func run_probe() -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	var capture := AudioEffectCapture.new()
	capture.buffer_length = 3.0
	AudioServer.add_bus_effect(master_bus, capture, AudioServer.get_bus_effect_count(master_bus))

	var game := (load("res://main.tscn") as PackedScene).instantiate()
	root.add_child(game)
	var music := game.get_node("BackgroundMusic") as AudioStreamPlayer
	await create_timer(1.0).timeout
	var music_result := capture_signal(capture)
	var music_stream := music.stream as AudioStreamWAV
	print("AUDIO_PROBE music playing=%s position=%.3f length=%.3f format=%d mix_rate=%d bytes=%d loop_mode=%d loop_begin=%d loop_end=%d frames=%d peak=%.6f rms=%.6f" % [
		music.playing,
		music.get_playback_position(),
		music_stream.get_length(),
		music_stream.format,
		music_stream.mix_rate,
		music_stream.data.size(),
		music_stream.loop_mode,
		music_stream.loop_begin,
		music_stream.loop_end,
		int(music_result.frames),
		float(music_result.peak),
		float(music_result.rms)
	])

	music.stop()
	capture.clear_buffer()
	var hover := AudioStreamPlayer.new()
	hover.bus = &"Master"
	hover.volume_db = -8.0
	hover.stream = load("res://audio/cc0/hover_01.wav")
	root.add_child(hover)
	hover.play()
	await create_timer(0.2).timeout
	var hover_result := capture_signal(capture)
	print("AUDIO_PROBE hover playing=%s frames=%d peak=%.6f rms=%.6f" % [
		hover.playing,
		int(hover_result.frames),
		float(hover_result.peak),
		float(hover_result.rms)
	])

	AudioServer.remove_bus_effect(master_bus, AudioServer.get_bus_effect_count(master_bus) - 1)
	quit(0 if float(music_result.peak) > 0.01 else 1)


func capture_signal(capture: AudioEffectCapture) -> Dictionary:
	var available := capture.get_frames_available()
	var frames := capture.get_buffer(available)
	var peak := 0.0
	var energy := 0.0
	var sample_count := 0
	for frame in frames:
		for sample in [frame.x, frame.y]:
			var magnitude := absf(sample)
			peak = maxf(peak, magnitude)
			energy += sample * sample
			sample_count += 1
	return {
		"frames": frames.size(),
		"peak": peak,
		"rms": sqrt(energy / maxf(1.0, float(sample_count)))
	}
