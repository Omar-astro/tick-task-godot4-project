extends Control

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var texture_button: TextureRect = $CanvasLayer/TextureButton
@onready var timer: Timer = $Timer
var close := false
@onready var delay: Timer = $delay

func _on_audio_stream_player_finished() -> void:
	timer.wait_time = 3
	if !close:
		audio_stream_player.play()
		delay.start()
		timer.start()
		close = true
	elif close:
		queue_free()

func _on_delay_timeout() -> void:
	texture_button.visible = true
