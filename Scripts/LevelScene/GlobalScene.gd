extends Node

var coins := 20 # <- GLOBAL COINS
var temp_coins: int
var tasks_number := 1 # <- GLOBAL TASK_NUMBER
var VARIABLE = "user://TickTask.json"
var music_volume
var SFX_volume

var time_passed := 0.0 # In seconds
var final_time : = 0.0
var is_running := true
var lives := 3
var temp1 : = true
var Personal_best := 0.0

@onready var coins_label: Label = $"../UI/HBoxContainer/Label"
@onready var stop_watch: Timer = $"../StopWatch"
@onready var label_2: Label = $"../UI/Label2"
@onready var tracking_bar: VBoxContainer = $"../UI/TrackingBar/ScrollContainer/VBoxContainer"

@export var Warning_color :Color
@export var Last_warning_color :Color
@export var lost_color :Color
@onready var score: Node = $"../Score"
@onready var transition = $"/root/Transition"
var pause_menu := false
@onready var pause_screen: CanvasLayer = $"../Pause screen"

func _ready() -> void:
	load_file()
	stop_watch.wait_time = 1.0
	stop_watch.one_shot = false
	stop_watch.timeout.connect(_on_timer_tick)
	stop_watch.start()
	pass

func save_file():
	var data = {}
	if score.TotalScore <= Personal_best:
		data = {"Music Volume": music_volume,
				"SFX Volume": SFX_volume,
				"Personal Best": Personal_best}
	else:
		data = {"Music Volume": music_volume,
				"SFX Volume": SFX_volume,
				"Personal Best": score.TotalScore}
	var json_file = JSON.stringify(data)
	var file = FileAccess.open(VARIABLE, FileAccess.WRITE)
	file.store_string(json_file)
	file.close()
	#print("saved succefully")

func load_file():
	if FileAccess.file_exists(VARIABLE):
		var file = FileAccess.open(VARIABLE, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		var result = JSON.parse_string(json_string)
		if result is Dictionary:
			#print('Loaded data: ', result)
			#block_1.position.x = result['po1'][0]
			music_volume = result['Music Volume'] 
			var db_value = lerp(-40, 0, music_volume / 100.0) if music_volume != 0 else -80
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BG Music"), db_value)
	
			SFX_volume = result['SFX Volume']
			var db_value2 = lerp(-40, 0, SFX_volume / 100.0) if SFX_volume != 0 else -80
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db_value2)
			
			Personal_best = result['Personal Best']
		else:
			print('file not save or corrupted')
	else:
		print('no file found')

func format_number_short(value: float) -> String:
	var abs_val = abs(value)
	var suffix := ""
	var num := value

	if abs_val >= 1_000_000_000:
		suffix = "B"
		num = value / 1_000_000_000.0
	elif abs_val >= 1_000_000:
		suffix = "M"
		num = value / 1_000_000.0
	elif abs_val >= 1_000:
		suffix = "k"
		num = value / 1_000.0

	return "%.1f%s" % [num, suffix]

func _on_timer_tick():
	if is_running:
		time_passed += 1.0
		_update_label()

func _update_label():
	# Optional display formatting
	var minutes = int(time_passed) / 60
	var seconds = int(time_passed) % 60
	label_2.text = "%02d:%02d" % [minutes, seconds]

func lose_life():
	lives -= 1
	if lives <= 0:
		
		game_over()

func on_shot_pause():
	if temp1:
		is_running = false
		final_time = time_passed
		stop_watch.stop()
		temp1 = false

func game_over():
	print("Game Over! Time: ", time_passed, " seconds")
	# You can emit a signal or change scene here

func _process(delta: float) -> void:
	coins_label.text = str(format_number_short(coins))
	
	
	
	if Input.is_action_just_pressed("Pause"):
		pause_menu = true
	
	if pause_menu:
		pause_screen.visible = true
		get_tree().paused = true
	else:
		pause_screen.visible = false
		get_tree().paused = false
	
	#TRACKING BAR
	var task_info := []
	# Loop through all tasks and collect their timer's time_left and name
	for task in get_tree().get_nodes_in_group("Task"):
		if task.has_node("Timer"):
			var t = task.get_node("Timer")
			if t is Timer:
				task_info.append({
				"name": task.name,
				"time": t.time_left,
				"wait": t.wait_time
				})
	
	# Sort the list by time_left ascending
	task_info.sort_custom(func(a, b): return a["time"] < b["time"])
	
	# Clear previous display
	for child in tracking_bar.get_children():
		child.queue_free()
	
	# Add labels with name + time and color logic
	for item in task_info:
		var label = Label.new()
		label.text = "%s: %ds" % [item["name"], round(item["time"])]

		var percentage = item["time"] / item["wait"]
		if percentage == 0:
			label.modulate = lost_color
		elif percentage <= 0.25:
			label.modulate = Last_warning_color
		elif percentage <= 0.5:
			label.modulate = Warning_color
		# else default color (white)
		
		var font = load("res://Others/Fonts/VT323-Regular.ttf") as Font
		label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 20)
		
		tracking_bar.add_child(label)
	
	
	#if Input.is_action_just_pressed("Debug1"):
		#coins += 50

func _on_task_spawner_task_spawned() -> void:
	#update_list()
	pass

func _on_Menu_pressed() -> void:
	pause_menu = false
	save_file()
	transition.transition_to_scene("res://Main Scenes/main_menu.tscn")

func _on_Restart_pressed() -> void:
	save_file()
	transition.transition_to_scene("res://Main Scenes/Game_Scene.tscn")

func _on_ResumeButton_pressed() -> void:
	#print("pressed")
	pause_menu = false
