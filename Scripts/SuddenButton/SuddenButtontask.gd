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
@onready var lever_pull: Node2D = $"../../.."
@onready var done: ColorRect = $"../Done"
@onready var icon: Sprite2D = $"../../../icon"

@onready var sudden_gap: Timer = $Game/SuddenGap
@onready var Sudden_button: Button = $Game/Button
@export var color_default: Color
var temp3 := false
var press_ready := false
var done_visible := false

#endregion

func _ready() -> void:
	set_time_random()

func task_Done():
	if !task_lost:
		emit_signal("lever_task_done")

func one_tick_task_func():	
	emit_signal("tick_task_done")
	$"../../../SFX/Success".play()
	global.add_coins()
	if !task_lost:
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
	if Input.is_action_just_pressed("Debug1"):
		start_timer()
	
	if done_visible:
		done.visible = false
		icon.modulate = color_default
	
	if global.paused:
		freeze_label.visible = true
		freeze_label.text = "+ " + str("%.1f" % freeze_time.time_left)
	else:
		freeze_label.visible = false
	
	upgrade_3.text = "Sudden Time +" + str(task_level) ##CHANGE THIS EVERY TASK
	
	if auto_bot:
		auto_bot_fun()

func task_upgrade():
	if task_level < 5:
		var time = sudden_gap.wait_time
		sudden_gap.wait_time = time + 2
		task_level += 1
	level.text = "Time Level: " + str(task_level) if task_level < 5 else "Time Level: MAX"

func set_time_random():
	Sudden_button.text = "Don't Press"
	var time = randf_range(1, 5)
	print(time)
	sudden_gap.start(time)

func start_timer():
	sudden_gap.stop()
	press_ready = true
	Sudden_button.text = "PRESS"
	timer.start()
	print("time started")
	lever_pull.Danger_track = false

func _on_area_2d_mouse_entered() -> void:
	Mouse_in = true
	print("new in")

func _on_area_2d_mouse_exited() -> void:
	Mouse_in = false
	print("new out")

func _on_button_pressed() -> void:
	if press_ready:
		one_tick_task_done()
		set_time_random()
		timer.stop()
		lever_pull.Danger_track = true
		lever_pull.set_back()
		press_ready = false
		done_visible = true
	else:
		sudden_gap.stop()
		timer.emit_signal("timeout")

func _on_sudden_gap_timeout() -> void:
	print("ended")
	done_visible = false
	start_timer()
