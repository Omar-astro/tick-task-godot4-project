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

var rotating = false
var current_rotation = 0.0
var rotation_speed = 72.0  # degrees per second
var return_speed = 120.0    # degrees per second
var full_turn = 360.0
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
	if rotating:
		var delta_rotation = rotation_speed * delta
		current_rotation += delta_rotation
		Gear.rotation_degrees += delta_rotation
	
		# Check if completed a full turn
		if current_rotation >= full_turn:
			completed_turn = true
			current_rotation = 0.0  # Reset rotation tracking
			rotating = false  # Stop unless you want to keep going
			
			task_completed = true
			
			#task_Done()
			if temp1:
				one_tick_task_done()
		elif current_rotation == full_turn / 2:
			temp1 = false
		else:
			task_completed = false
	
	elif not completed_turn:
		# Return to original position
		if current_rotation > 0:
			var delta_rotation = return_speed * delta
			current_rotation -= delta_rotation
			Gear.rotation_degrees -= delta_rotation
	
			if current_rotation <= 0:
				current_rotation = 0.0
				Gear.rotation_degrees = 0.0  # Snap cleanly
	
	if global.paused:
		freeze_label.visible = true
		freeze_label.text = "+ " + str("%.1f" % freeze_time.time_left)
	else:
		freeze_label.visible = false
	
	upgrade_3.text = "Gear Speed +" + str(task_level) ##CHANGE THIS EVERY TASK
	
	if auto_bot:
		auto_bot_fun()

func task_upgrade():
	if task_level < 5:
		rotation_speed += 72
		task_level += 1
	level.text = "Gear Speed: " + str(task_level) if task_level < 5 else "Gear Speed: MAX"

func _on_area_2d_mouse_entered() -> void:
	Mouse_in = true
	print("new in")

func _on_area_2d_mouse_exited() -> void:
	Mouse_in = false
	print("new out")

func _on_button_button_down() -> void:
	rotating = true
	completed_turn = false

func _on_button_button_up() -> void:
	rotating = false
