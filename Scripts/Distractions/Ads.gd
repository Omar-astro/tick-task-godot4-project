extends Control

@onready var label: Label = $CanvasLayer/Label

@onready var timer: Timer = $Timer
@onready var button: Button = $CanvasLayer/Button


func _process(delta: float) -> void:
	label.text = "Skip in..." + str(int(ceil(timer.time_left)))

func _on_timer_timeout() -> void:
	label.visible = false
	button.visible = true


func _on_button_pressed() -> void:
	queue_free()
