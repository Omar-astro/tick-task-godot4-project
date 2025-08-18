extends CanvasLayer

@onready var task: Control = $Control/task
@onready var upgrades: Control = $Control/upgrades
@onready var button: Button = $Control/HBoxContainer/Button
@onready var button_2: Button = $Control/HBoxContainer/Button2
@onready var lever_pull: Node2D = $".."


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("F1") and lever_pull.window_open:
		#task.visible = true
		#upgrades.visible = false
		button.emit_signal("pressed")
	elif Input.is_action_just_pressed("F2") and lever_pull.window_open:
		#upgrades.visible = true
		#task.visible = false
		button_2.emit_signal("pressed")


func _on_task_button_pressed() -> void:
	task.visible = true
	upgrades.visible = false

func _on_button_2_pressed() -> void:
	upgrades.visible = true
	task.visible = false
