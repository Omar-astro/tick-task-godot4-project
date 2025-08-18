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

@onready var success_task: AudioStreamPlayer = $"../../../SFX/SuccessTask"
@onready var fail_purchase: AudioStreamPlayer = $"../../../SFX/fail purchase"
@onready var charge_bar: ProgressBar = $Game/ProgressBar
@onready var charge_button: Button = $Game/Button
@onready var battery_level: ColorRect = $"Game/Battery Level"
@onready var Percent_label: Label = $Game/Label
@onready var penalty_time: Timer = $"Game/Penalty time"
var tween_duration := 5.0  # seconds to fully charge
var gap_size := 5.0       # success zone width
var zone_min: float
var zone_max: float
var tween: Tween
var tween2: Tween
#endregion

func _ready() -> void:
	_randomize_zone()
	charge_bar.value = 0

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

func _randomize_zone() -> void:
	zone_min = floor(randf_range(10, 70))
	zone_max = floor(min(zone_min + gap_size, charge_bar.max_value))
	
	# Visual zone update (if you want to see the zone)
	var bar_width := charge_bar.size.x
	var zone_start_x := (zone_min / charge_bar.max_value) * bar_width
	var zone_end_x := (zone_max / charge_bar.max_value) * bar_width
	var zone_width := zone_end_x - zone_start_x
	
	#zone_visual.position.x = charge_bar.position.x + zone_start_x
	#zone_visual.size.x = zone_width
	#zone_visual.size.y = charge_bar.size.y
	#zone_visual.modulate = Color(0.2, 1.0, 0.2, 0.4)  # transparent green

func _process(delta: float) -> void:
	Percent_label.text = str(zone_min) + "% - " + str(zone_max) + "%"
	
	
	if global.paused:
		freeze_label.visible = true
		freeze_label.text = "+ " + str("%.1f" % freeze_time.time_left)
	else:
		freeze_label.visible = false
	
	upgrade_3.text = "Gap Size +" + str(task_level) ##CHANGE THIS EVERY TASK
	
	if auto_bot:
		auto_bot_fun()

func task_upgrade():
	if task_level < 5:
		gap_size += 5
		task_level += 1
	level.text = "Gap Size: " + str(task_level) if task_level < 5 else "Gap Size: MAX"

func _on_area_2d_mouse_entered() -> void:
	Mouse_in = true
	print("new in")

func _on_area_2d_mouse_exited() -> void:
	Mouse_in = false
	print("new out")

func _on_button_button_down() -> void:
	#print("⚡ Button down: Start tween")
	tween = create_tween()
	tween.tween_property(charge_bar, "value", 100.0, tween_duration)
	
	var base_size := 12.285
	var target_size := 333.84
	battery_level.size.y = base_size
	tween2 = create_tween()
	tween2.tween_property(battery_level, "size:y", target_size, tween_duration)

func _on_button_button_up() -> void:
	#print("🛑 Button up: Stop tween and check")
	
	if tween:
		tween.kill()
		tween2.kill()
	
	var value := charge_bar.value
	#print("🔍 Charge value:", value, "Target zone:", zone_min, "→", zone_max)
	
	if value >= zone_min and value <= zone_max:
		one_tick_task_done()
		#print("✅ Success!")
		#success_task.play()
		##Logic
	else:
		#print("❌ Fail!")
		penalty_time.start()
		charge_button.disabled = true
		fail_purchase.play()
		##Logic
	
	charge_bar.value = 0
	_randomize_zone()

func _on_penalty_time_timeout() -> void:
	charge_button.disabled = false
