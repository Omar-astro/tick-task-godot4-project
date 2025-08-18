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

@onready var color_word: Label = $Game/ColorWord
@onready var button_1: TextureButton = $Game/VBoxContainer/HBoxContainer/Button1
@onready var button_2: TextureButton = $Game/VBoxContainer/HBoxContainer/Button2
@onready var button_3: TextureButton = $Game/VBoxContainer/HBoxContainer/Button3
@onready var button_4: TextureButton = $Game/VBoxContainer/HBoxContainer2/Button4
@onready var button_5: TextureButton = $Game/VBoxContainer/HBoxContainer2/Button5
@onready var button_6: TextureButton = $Game/VBoxContainer/HBoxContainer2/Button6
@onready var button_7: TextureButton = $Game/VBoxContainer/HBoxContainer3/Button7
@onready var button_8: TextureButton = $Game/VBoxContainer/HBoxContainer3/Button8
@onready var button_9: TextureButton = $Game/VBoxContainer/HBoxContainer3/Button9


var buttons = []
var buttons_size := 9
var color_dict = {
	"Red": Color(1, 0, 0),
	"Green": Color(0, 1, 0),
	"Blue": Color(0, 0, 1),
	"Yellow": Color(1, 1, 0),
	"Cyan": Color(0, 1, 1),
	"Magenta": Color(1, 0, 1),
	"Orange": Color(1, 0.5, 0),
	"Purple": Color(0.5, 0, 0.5),
	"Pink": Color(1, 0.4, 0.7),
	"Brown": Color(0.6, 0.3, 0.1),
	"Teal": Color(0, 0.5, 0.5),
	"Lime": Color(0.7, 1, 0),
	"Indigo": Color(0.3, 0, 0.5),
	"Grey": Color(0.5, 0.5, 0.5),
	"White": Color(1, 1, 1)
}

var written_color
var shown_color
var correct_button_number
var chossen_colors = []
@onready var false_timer: Timer = $Game/falseTimer


#endregion

func _ready() -> void:
	buttons = [button_1,button_2,button_3,button_4,button_5,button_6,button_7,button_8,button_9]
	task_code()

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
	if buttons_size != buttons.size():
		buttons[-1].visible = false
		buttons.pop_back()
	
	#if Input.is_action_just_pressed("Debug1"):
		#task_upgrade()
	
	if global.paused:
		freeze_label.visible = true
		freeze_label.text = "+ " + str("%.1f" % freeze_time.time_left)
	else:
		freeze_label.visible = false
	
	upgrade_3.text = "Less Colors +" + str(task_level) ##CHANGE THIS EVERY TASK
	
	if auto_bot:
		auto_bot_fun()

func task_upgrade():
	if task_level < 5:
		buttons_size -= 1
		task_level += 1
	level.text = "Less Colors: " + str(task_level) if task_level < 5 else "Less Colors: MAX"

func _on_area_2d_mouse_entered() -> void:
	Mouse_in = true
	print("new in")

func _on_area_2d_mouse_exited() -> void:
	Mouse_in = false
	print("new out")



func task_code():
	for button in buttons:
			button.visible = true
	chossen_colors.clear()
	shown_color = get_random_color_value(color_dict)
	written_color = get_random_color_name(color_dict)
	color_word.modulate = shown_color
	color_word.text = written_color
	var random_correct_button:TextureButton = buttons[randi() % buttons.size()]
	print(written_color)
	random_correct_button.modulate = color_dict[written_color]
	chossen_colors.append(color_dict[written_color])
	correct_button_number = random_correct_button.get_meta("ButtonNumber")
	print(random_correct_button.get_meta("ButtonNumber"))
	for button:TextureButton in buttons:
		if button != random_correct_button:
			button.modulate = get_notrand_color_value(color_dict)

func get_random_color_value(color_dict: Dictionary) -> Color:
	var values = color_dict.values()
	return values[randi() % values.size()]

func get_random_color_name(color_dict: Dictionary) -> String:
	var keys = color_dict.keys()
	return keys[randi() % keys.size()]

func get_notrand_color_value(color_dict: Dictionary) -> Color:
	var final_value = shown_color
	while final_value in chossen_colors:
		var values = color_dict.values()
		final_value = values[randi() % values.size()]
	chossen_colors.append(final_value)
	return final_value

func get_notrand_color_name(color_dict: Dictionary) -> String:
	var final_key = written_color
	while written_color == final_key:
		var keys = color_dict.keys()
		final_key = keys[randi() % keys.size()]
	return final_key

func _on_colorbutton_pressed(number: int) -> void:
	if number == correct_button_number:
		print("correctt")
		task_code()
		one_tick_task_done()
	else:
		print("INcrorrect")
		false_timer.start()
		for button in buttons:
			button.visible = false
		color_word.modulate = Color.RED
		color_word.text = "INCORRECT"
		fail_purchase.play()

func _on_false_timer_timeout() -> void:
	task_code()
