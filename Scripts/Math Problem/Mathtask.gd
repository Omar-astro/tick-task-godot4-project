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
@onready var fail_purchase: AudioStreamPlayer = $"../../../SFX/fail purchase"

@onready var user_label: Label = $Game/UserLabel
@onready var label: Label = $Game/Label

var current_number
var target_number : int
var target1 : int
var target2 : int
var limit : int = 999
var numString := ""

#endregion

func _ready() -> void:
	generate_random()

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
	user_label.text = str(current_number) if current_number != null else ""
	label.text = str(target1) + " + " + str(target2) + " = ??"
	
	#if Input.is_action_just_pressed("Debug1"):
		#task_upgrade()
	
	if global.paused:
		freeze_label.visible = true
		freeze_label.text = "+ " + str("%.1f" % freeze_time.time_left)
	else:
		freeze_label.visible = false
	
	upgrade_3.text = "Number Limit +" + str(task_level) ##CHANGE THIS EVERY TASK
	
	if auto_bot:
		auto_bot_fun()

func task_upgrade():
	if task_level < 5:
		limit -= 247
		task_level += 1
	level.text = "Number Limit: " + str(task_level) if task_level < 5 else "Number Limit: MAX"

func _on_area_2d_mouse_entered() -> void:
	Mouse_in = true
	print("new in")

func _on_area_2d_mouse_exited() -> void:
	Mouse_in = false
	print("new out")



func generate_random():
	target1 = randi_range(-limit, limit)
	target2 = randi_range(-limit, limit)
	target_number = target1 + target2
	#print(target_number)

func clear_number():
	numString = ""
	current_number = null

func add_to_number(num: int):
	numString += str(num)
	current_number = int(numString)

func check_true():
	if current_number == target_number:
		one_tick_task_done()
		clear_number()
		generate_random()
	else:
		fail_purchase.play()

func _on_NumberButton_pressed(Number: int) -> void:
	add_to_number(Number)

func _on_clear_pressed() -> void:
	clear_number()

func _on_submit_pressed() -> void:
	check_true()

func _on_negative_pressed() -> void:
	if current_number != null:
		current_number *= -1
