extends Control

#region vars
var holding := false
var Mouse_in := false
var task_lost := false
var task_completed := false
var temp1 = true
var temp2 = true
@export var auto_bot := false
var task_level := 1
var min_y := 206.0
var max_y := 470.0
var lever_speed := 100.0  # pixels per second
var return_speed := 600.0
var fixed_x := 528.0
var target_y := 206.0  # The Y we want to move toward

signal lever_task_done
signal tick_task_done

@export var correct_color: Color
@export var default_color: Color

@onready var lever: TextureRect = $Lever
@onready var level: Label = $UI/Level
@onready var freeze_label: Label = $"UI/Freeze Label"
@onready var global: Control = $"../../../Global"
@onready var upgrade_3: Button = $"../upgrades/HBoxContainer/VBoxContainer/HBoxContainer/Upgrade 3"
@onready var freeze_time: Timer = $"../../../freeze time"
@onready var timer: Timer = $"../../../Timer"



#endregion


func task_Done():
	if !task_lost:
		if lever.position.y >= max_y - 5:
			emit_signal("lever_task_done")
			task_completed = true
		else:
			task_completed = false

func one_tick_task_func():	
	emit_signal("tick_task_done")
	$"../../../SFX/Success".play()
	global.add_coins()
	if !task_lost:
		emit_signal("lever_task_done")

func one_tick_task_done():
	if !task_lost:
		if temp1 and lever.position.y >= max_y - 5:
			one_tick_task_func()
			temp1 = false
		elif lever.position.y == min_y:
			temp1 = true

func auto_bot_fun():
	if timer.time_left < timer.wait_time/2 and temp2:
		one_tick_task_func()
		temp2 = false
	elif timer.time_left > timer.wait_time/2:
		temp2 = true

func _process(delta: float) -> void:
	task_Done()
	one_tick_task_done()
	
	if Input.is_action_just_pressed("Click") and Mouse_in:
		holding = true
	elif Input.is_action_just_released("Click"):
		holding = false
		target_y = min_y  # 🆕 <- Return target when released

	if holding:
		var mouse_y = get_viewport().get_mouse_position().y
		target_y = clamp(mouse_y, min_y, max_y)

	# Choose speed depending on holding or returning
	var speed := 0.0
	if holding:
		speed = lever_speed
	else:
		speed = return_speed
	
	var current_y = lever.position.y
	var new_y = move_toward(current_y, target_y, speed * delta)
	lever.position = Vector2(fixed_x, new_y)
	
	if global.paused:
		freeze_label.visible = true
		freeze_label.text = "+ " + str("%.1f" % freeze_time.time_left)
	else:
		freeze_label.visible = false
	
	upgrade_3.text = "Lever Speed +" + str(task_level)
	
	if auto_bot:
		auto_bot_fun()


func task_upgrade():
	if task_level < 5:
		lever_speed += 200
		task_level += 1
	level.text = "Lever Speed: " + str(task_level) if task_level < 5 else "Lever Speed: MAX"

func _on_area_2d_mouse_entered() -> void:
	Mouse_in = true
	#print("new in")

func _on_area_2d_mouse_exited() -> void:
	Mouse_in = false
	#print("new out")
