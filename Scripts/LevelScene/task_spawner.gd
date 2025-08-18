extends Node

var task_number: int = 1
var no_of_distractions := 0

@export var task_scene: PackedScene = preload("res://Task Scenes/Rotate_gear.tscn")

var tasks = {"Task 1" : preload("res://Task Scenes/Rotate_gear.tscn"),
			"Task 2": preload("res://Task Scenes/lever_Pull_Task.tscn"),
			"Task 3": preload("res://Task Scenes/BatteryCharge.tscn"),
			"Task 4": preload("res://Task Scenes/Time_reaction.tscn"),
			"Task 5": preload("res://Task Scenes/Captcha.tscn"),
			"Task 6": preload("res://Task Scenes/MathProblem.tscn"),
			"Task 7": preload("res://Task Scenes/ColorConfusion.tscn")}
#"Task 5": preload("res://Task Scenes/SuddenButton.tscn")		HAS A MASSIVE BUG
var remaining_tasks := []

var distractions ={"dist1": preload("res://Distractions/ADS/apples_ad.tscn"),
					"dist2": preload("res://Distractions/ADS/Pizza_ad.tscn"),
					"dist3": preload("res://Distractions/ADS/mask_ad.tscn"),
					"dist4": preload("res://Distractions/ADS/Moon_ad.tscn"),
					"dist5": preload("res://Distractions/ADS/Spider_ad.tscn"),
					"dist6": preload("res://Distractions/ADS/petRock_ad.tscn"),
					"dist7": preload("res://Distractions/ADS/water_ad.tscn"),
					"dist8": preload("res://Distractions/ADS/fake_reward.tscn"),
					"dist9": preload("res://Distractions/ADS/jumpscare.tscn"),
					"dist10": preload("res://Distractions/PassingCat.tscn")}

@onready var spawn_task_time: Timer = $"../Spawn task time"
@onready var distraction_time: Timer = $"../Distraction time"

@export var min_distance := 150.0
@export var max_distance := 300.0

signal task_spawned

var spawned_tasks := []

func _ready():
	# Spawn the first task in center
	distraction_time.start()
	$"delay spawn".start()
	reset_remaining_tasks()

func reset_remaining_tasks():
	remaining_tasks = tasks.values()  # Just the scenes, not the keys
	remaining_tasks.shuffle()

func set_random_task_scene():
	if remaining_tasks.is_empty():
		reset_remaining_tasks()
	
	task_scene = remaining_tasks.pop_back()

func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("Debug1"):
		#spawn_near_random_task()
	pass

func spawn_near_random_task():
	if spawned_tasks.is_empty():
		return

	var base_task = spawned_tasks[randi() % spawned_tasks.size()]
	var base_pos = base_task.global_position

	var new_pos: Vector2
	while true:
		new_pos = get_random_position_around(base_pos)
		if is_position_clear(new_pos):
			break  # Found a valid spot, exit loop

	var new_task = spawn_task(new_pos)
	spawned_tasks.append(new_task)

func is_position_clear(pos: Vector2) -> bool:
	var clearance_radius = 150.0  # Distance required between tasks
	for task in get_tree().get_nodes_in_group("Task"):
		if task.global_position.distance_to(pos) < clearance_radius:
			return false
	return true

func get_random_position_around(center: Vector2) -> Vector2:
	# Pick random angle and distance
	var angle = randf() * TAU  # TAU = 2π
	var distance = randf_range(min_distance, max_distance)
	var offset = Vector2.RIGHT.rotated(angle) * distance
	return center + offset

func spawn_task(position: Vector2) -> Node2D:
	set_random_task_scene()
	#task_scene = preload("res://Task Scenes/ColorConfusion.tscn")
	
	var task = task_scene.instantiate()
	task.position = position
	
	var Global_node = task.get_node("Global")
	var name_of_task = Global_node.Task_Name
	task.name = str(name_of_task) + " | Task_%d" % task_number
	
	var task_global_node = task.get_node("Global")
	task_global_node.task_number = task_number
	task_number += 1
	
	var target_node = get_tree().root.get_node("Main")
	target_node.add_child(task)
	
	$"../AnimationPlayer".play("Spawn effect")
	$"../AnimationPlayer/spawn".play()
	$"../AnimationPlayer/Sprite2D".position = task.position
	
	emit_signal("task_spawned")
	return task

func _on_delay_spawn_timeout() -> void:
	var new_task = spawn_task(Vector2.ZERO)
	spawned_tasks.append(new_task)
	pass

func _on_spawn_task_time_timeout() -> void:
	var time = spawn_task_time.wait_time
	time += 20
	spawn_near_random_task()
	spawn_task_time.start(time)

func spawn_random_distraction():
	no_of_distractions += 1
	var random_scene = distractions.values().pick_random()
	var instance = random_scene.instantiate()
	add_child(instance)

func _on_distraction_time_timeout() -> void:
	spawn_random_distraction()
	distraction_time.wait_time = randf_range(10.0, 60.0)
	distraction_time.start()
