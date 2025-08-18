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

var rotating = false
var rotation_speed = 72.0  # degrees per second
var completed_turn = false

signal lever_task_done
signal tick_task_done

@export var correct_color: Color
@export var default_color: Color

@onready var Gear: TextureRect = $Gear/TextureRect
@onready var level: Label = $UI/Level
@onready var freeze_label: Label = $"UI/Freeze Label"
@onready var global: Control = $"../../../Global"
@onready var upgrade_3: Button = $"../upgrades/HBoxContainer/VBoxContainer/HBoxContainer/Upgrade 3"
@onready var freeze_time: Timer = $"../../../freeze time"
@onready var timer: Timer = $"../../../Timer"

@onready var reaction_button: Button = $Game/ReactionButton
@onready var reaction_time: Timer = $Game/ReactionTime
@onready var gap_time: Timer = $Game/GapTime
@onready var false_press: Timer = $Game/false_press
@onready var correct_1: TextureRect = $Game/HBoxContainer/Correct1
@onready var correct_2: TextureRect = $Game/HBoxContainer/Correct2
@onready var correct_3: TextureRect = $Game/HBoxContainer/Correct3
@onready var success_task: AudioStreamPlayer = $"../../../SFX/SuccessTask"
@onready var fail_purchase: AudioStreamPlayer = $"../../../SFX/fail purchase"
@export var start_color: Color
@export var wait_color: Color
@export var press_color: Color
@export var false_press_color: Color
var readyBool := true
var numbers_pressed := 0
var can_press := false

#endregion

func task_Done():
	if !task_lost:
		emit_signal("lever_task_done")

func one_tick_task_func():	
	if !task_lost:
		emit_signal("tick_task_done")
		$"../../../SFX/Success".play()
		global.add_coins()
		emit_signal("lever_task_done")

func one_tick_task_done():
	if !task_lost:
		one_tick_task_func()

func auto_bot_fun():
	if timer.time_left < timer.wait_time/2 and temp2:
		one_tick_task_func()
		temp2 = false
	elif timer.time_left > timer.wait_time/2:
		temp2 = true

func _process(delta: float) -> void:
	if numbers_pressed == 0:
		correct_1.modulate = start_color
		correct_2.modulate = start_color
		correct_3.modulate = start_color
	if numbers_pressed == 1:
		correct_1.modulate = press_color
		correct_2.modulate = start_color
		correct_3.modulate = start_color
	if numbers_pressed == 2:
		correct_1.modulate = press_color
		correct_2.modulate = press_color
		correct_3.modulate = start_color
	
	if global.paused:
		freeze_label.visible = true
		freeze_label.text = "+ " + str("%.1f" % freeze_time.time_left)
	else:
		freeze_label.visible = false
	
	upgrade_3.text = "reaction time +" + str(task_level) ##CHANGE THIS EVERY TASK
	
	if auto_bot:
		auto_bot_fun()

func task_upgrade():
	if task_level < 5:
		var time = reaction_time.wait_time
		reaction_time.wait_time = time + 0.2
		task_level += 1
	level.text = "Gap Size: " + str(task_level) if task_level < 5 else "Gap Size: MAX"

func _on_area_2d_mouse_entered() -> void:
	Mouse_in = true
	print("new in")

func _on_area_2d_mouse_exited() -> void:
	Mouse_in = false
	print("new out")

func false_press_func():
	#print("failed")
	fail_purchase.play()
	gap_time.stop()
	numbers_pressed = 0
	false_press.start()
	reaction_button.text = "FAIL"
	reaction_button.modulate = false_press_color
	reaction_button.disabled = true
	can_press = false

func _on_reaction_button_pressed() -> void:
	#print("Press: ", readyBool, " | ", numbers_pressed, " | ", can_press)
	if !readyBool and !can_press:
		false_press_func()
	
	if readyBool:
		readyBool = false
		reaction_button.text = "Wait..."
		reaction_button.modulate = wait_color
		var random_time = randf_range(0.5, 4.0)
		gap_time.start(random_time)
	
	if !readyBool and can_press and numbers_pressed == 2:
		numbers_pressed = 0
		one_tick_task_done()
		reaction_button.text = "Start"
		reaction_button.modulate = start_color
		readyBool = true
		can_press = false
		reaction_time.stop()
	elif !readyBool and can_press:
		numbers_pressed += 1
		reaction_button.text = "Wait..."
		reaction_button.modulate = wait_color
		var random_time = randf_range(0.5, 4.0)
		gap_time.start(random_time)
		can_press = false
		reaction_time.stop()
		success_task.play()

func _on_reaction_time_timeout() -> void:
	#print("reaction time: ", readyBool, " | ", numbers_pressed, " | ", can_press)
	false_press_func()

func _on_gap_time_timeout() -> void:
	can_press = true
	#print("gap Time: ", readyBool, " | ", numbers_pressed, " | ", can_press)
	reaction_button.text = "PRESS"
	reaction_button.modulate = press_color
	reaction_time.start()

func _on_false_press_timeout() -> void:
	#print("false press: ", readyBool, " | ", numbers_pressed, " | ", can_press)
	reaction_button.text = "Start"
	reaction_button.modulate = start_color
	reaction_button.disabled = false
	readyBool = true
