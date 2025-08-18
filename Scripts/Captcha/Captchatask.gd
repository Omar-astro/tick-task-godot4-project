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


@onready var Captcha_label: Label = $Game/Label
@onready var line_edit: LineEdit = $Game/LineEdit
var Captcha_length := 8
var Captcha :String

#endregion

func _ready() -> void:
	generate_captcha(Captcha_length)

func task_Done():
	if !task_lost:
		emit_signal("lever_task_done")

func one_tick_task_func():	
	if !task_lost:
		emit_signal("tick_task_done")
		$"../../../SFX/Success".play()
		global.add_coins()
		emit_signal("lever_task_done")
		generate_captcha(Captcha_length)
		line_edit.clear()

func one_tick_task_done():
	if !task_lost:
		one_tick_task_func()

func auto_bot_fun():
	if timer.time_left < timer.wait_time/2 and temp2:
		one_tick_task_func()
		temp2 = false
	elif timer.time_left > timer.wait_time/2:
		temp2 = true

func generate_captcha(length: int):
	var chars = "BCEFGHJKLMNOPQRTUVXYZbcefghjklmnopqrtuvxyz056789"
	var result := ""
	for i in length:
		result += chars[randi() % chars.length()]
	Captcha = result

func _process(delta: float) -> void:
	Captcha_label.text = Captcha
	
	if global.paused:
		freeze_label.visible = true
		freeze_label.text = "+ " + str("%.1f" % freeze_time.time_left)
	else:
		freeze_label.visible = false
	
	upgrade_3.text = "Word Size +" + str(task_level) ##CHANGE THIS EVERY TASK
	
	if auto_bot:
		auto_bot_fun()

func task_upgrade():
	if task_level < 5:
		Captcha_length -= 1
		task_level += 1
	level.text = "Word Size: " + str(task_level) if task_level < 5 else "Word Size: MAX"

func _on_area_2d_mouse_entered() -> void:
	Mouse_in = true
	print("new in")

func _on_area_2d_mouse_exited() -> void:
	Mouse_in = false
	print("new out")


func _on_line_edit_text_submitted(new_text: String) -> void:
	if line_edit.text == Captcha:
		one_tick_task_done()
	else:
		fail_purchase.play()
