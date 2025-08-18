extends Node2D

#region vars

var in_zone := false #just a test one
var flash := false
var flick1 := false
var condition1 := false
var window_open = false
var window_sound := true
var temp1 := true
var temp2 := true
var time_ready := true
var Danger_track := true

enum states{safe, halfway, danger, dead}
var time_state := states.safe

@export_group("Colors")
@export var color_default: Color
@export var color_hover: Color
@export var fail_color: Color
@export var warning_color: Color
@export var fade_warning_color: Color
@export var ending_color: Color
@export var fade_ending_color: Color
@export var lost_color: Color
@export var fade_lost_color: Color
@export var Transparent: Color
@export var correct_color: Color
@export var Freeze_color: Color

@onready var icon: Sprite2D = $icon
@onready var timer: float = $Timer.wait_time
@onready var time_left: float = $Timer.time_left
@onready var done: ColorRect = $CanvasLayer/Control/Done
@onready var canvas_layer: Control = $CanvasLayer/Control
@onready var task: Control = $CanvasLayer/Control/task
@onready var global: Control = $Global
@onready var flash_timer: Timer = $flash_timer
@onready var warning_SFX: AudioStreamPlayer = $SFX/warning
@onready var fail_task_SFX: AudioStreamPlayer = $"SFX/Fail task"

#endregion

func close_tab():
	window_sound = true
	var tween_out := create_tween()
	tween_out.tween_property(canvas_layer, "scale", Vector2(0.001, 0.001), 0.2)
	$SFX/close.play()

func timer_mangment():
	if Danger_track:
		if time_left == 0 and time_ready:
			time_state = states.dead
		elif time_left < timer - (timer * 0.75):
			time_state = states.danger
			#print("LAST SECONDS")
			flash_timer.wait_time = 0.2
		elif time_left < timer / 2:
			time_state = states.halfway
			#print("half time")
			flash_timer.wait_time = 0.5
			condition1 = true
		else:
			time_state = states.safe
			flick1 = false
			flash_timer.stop()

func color_mangment():
	if global.paused:
		icon.modulate = Freeze_color
		done.modulate = Freeze_color
		done.visible = true
	elif flash and time_state == states.halfway:
		warning_SFX.play()
		icon.modulate = warning_color
		done.modulate = fade_warning_color
		done.visible = true
	elif flash and time_state == states.danger:
		warning_SFX.play()
		icon.modulate = ending_color
		done.modulate = fade_ending_color
		done.visible = true
	elif time_state == states.dead:
		if temp1:
			fail_task_SFX.play()
			warning_SFX.stop()
			temp1 = false
		icon.modulate = lost_color
		done.modulate = fade_lost_color
		done.visible = true
	else:
		icon.modulate = color_default
		done.visible = false

func start_flash():
	flash_timer.start()

func set_back():
	flick1 = false
	flash_timer.stop()
	condition1 = false
	time_state = states.safe
	done.visible = false
	temp2 = true

func _process(delta: float) -> void:
	timer_mangment()
	color_mangment()
	
	if !Danger_track and temp2:
		condition1 = true
		time_state = states.danger
		#print("LAST SECONDS")
		flash_timer.wait_time = 0.2
		temp2 = false
	
	if $CanvasLayer/Control.scale == Vector2(1,1):
		window_open = true
	else:
		window_open = false
	
	if condition1 and not flick1:
		start_flash()
		flick1 = true
	
	if in_zone and Input.is_action_just_pressed("Click"):
		var tween_in := create_tween()
		tween_in.tween_property(canvas_layer, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if window_sound:
			$SFX/open.play()
			window_sound = false
	
	if Input.is_action_just_pressed("Exit") and window_open:
		close_tab()
	
	time_left = $Timer.time_left
	
	#task completed
	var task :bool = $CanvasLayer/Control/task.task_completed
	if task:
		$CanvasLayer/Control/task/UI/HBoxContainer/Time.modulate = correct_color
	else:
		$CanvasLayer/Control/task/UI/HBoxContainer/Time.modulate = color_default

func _on_area_2d_area_entered() -> void:
	in_zone = true
	icon.modulate = color_hover
	#print("entered")

func _on_area_2d_area_exited() -> void:
	in_zone = false
	icon.modulate = color_default
	#print("exited")

func _on_timer_timeout() -> void:
	print("LOST TASK (LEVER)")
	$Global.timer_node.stop()
	task.task_lost = true

func _on_task_lever_task_done() -> void:
	pass

func _on_flash_timer_timeout() -> void:
	if flash:
		flash = false
	elif !flash:
		flash = true
