extends Control

var VARIABLE = "user://TickTask.json"
var updating_music_controls = false
var last_volume_before_mute = 100  # default starting volume
var updating_SFX_controls = false
var last_SFX_volume_before_mute = 100
var personal_best = 0.0
var page_number := 1

@onready var AnimationTranstion = $"/root/Transition"
@onready var main: Control = $CanvasLayer/Main
@onready var settings: Control = $CanvasLayer/Settings
@onready var music_volume: HSlider = $CanvasLayer/Settings/Music_volume
@onready var SFX_volume: HSlider = $CanvasLayer/Settings/SFX_Volume
@onready var music_label: Label = $CanvasLayer/Settings/Music_volume/Label
@onready var SFX_label: Label = $CanvasLayer/Settings/SFX_Volume/Label2
@onready var music_texture_button: TextureButton = $CanvasLayer/Settings/Music_volume/TextureButton
@onready var SFX_texture_button: TextureButton = $CanvasLayer/Settings/SFX_Volume/TextureButton2
@onready var personal_label: Label = $CanvasLayer/LeaderBoard/Personal_label
@onready var leader_board: Control = $CanvasLayer/LeaderBoard
@onready var game_jam: Control = $"CanvasLayer/Game Jam"
@onready var tutorial: Control = $CanvasLayer/Tutorial
@onready var page_1: Control = $CanvasLayer/Tutorial/page1
@onready var page_2: Control = $CanvasLayer/Tutorial/page2
@onready var page_3: Control = $CanvasLayer/Tutorial/page3
@onready var page_4: Control = $CanvasLayer/Tutorial/page4
@onready var page_5: Control = $CanvasLayer/Tutorial/page5

func _ready():
	load_file()
	if music_volume.value > 0:
		last_volume_before_mute = music_volume.value
	if SFX_volume.value > 0:
		last_SFX_volume_before_mute = SFX_volume.value

func save_file():
	var data = {"Music Volume": music_volume.value,
				"SFX Volume": SFX_volume.value,
				"Personal Best": 0.0}
	var json_file = JSON.stringify(data)
	var file = FileAccess.open(VARIABLE, FileAccess.WRITE)
	file.store_string(json_file)
	file.close()
	print("saved succefully")

func load_file():
	if FileAccess.file_exists(VARIABLE):
		var file = FileAccess.open(VARIABLE, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		var result = JSON.parse_string(json_string)
		if result is Dictionary:
			print('Loaded data: ', result)
			#block_1.position.x = result['po1'][0]
			personal_best = result['Personal Best']
			music_volume.value = result['Music Volume']
			SFX_volume.value = result['SFX Volume']
		else:
			print('file not save or corrupted')
	else:
		print('no file found')

func _process(delta: float) -> void:
	$CanvasLayer/Tutorial/notes.text = str(page_number)
	if page_number == 1:
		page_1.visible = true
		page_2.visible = false
	elif page_number == 2:
		page_1.visible = false
		page_2.visible = true
		page_3.visible = false
	elif page_number == 3:
		page_2.visible = false
		page_3.visible = true
		page_4.visible = false
	elif page_number == 4:
		page_3.visible = false
		page_4.visible = true
		page_5.visible = false
	elif page_number == 5:
		page_4.visible = false
		page_5.visible = true
	
	personal_label.text = "Personal Best: " + str(personal_best)
	music_label.text = str(int(music_volume.value))
	var db_value = lerp(-40, 0, music_volume.value / 100.0) if music_volume.value != 0 else -80
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BG Music"), db_value)
	
	SFX_label.text = str(int(SFX_volume.value))
	var db_value2 = lerp(-40, 0, SFX_volume.value / 100.0) if SFX_volume.value != 0 else -80
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db_value2)

func _on_music_volume_changed(value):
	if updating_music_controls:
		return
	
	updating_music_controls = true
	
	# Track last non-zero volume
	if value > 0:
		last_volume_before_mute = value
		music_texture_button.button_pressed = false
	else:
		music_texture_button.button_pressed = true
	
	updating_music_controls = false

func _on_texture_button_pressed() -> void:
	if updating_music_controls:
		return
	
	updating_music_controls = true
	
	if music_texture_button.button_pressed:
		# Muted
		music_volume.value = 0
	else:
		# Unmuted — restore previous volume
		music_volume.value = last_volume_before_mute
	
	updating_music_controls = false

func _on_SFX_volume_changed(value):
	if updating_SFX_controls:
		return
	
	updating_SFX_controls = true
	
	# Track last non-zero volume
	if value > 0:
		last_SFX_volume_before_mute = value
		SFX_texture_button.button_pressed = false
	else:
		SFX_texture_button.button_pressed = true
	
	updating_SFX_controls = false

func _on_SFX_texture_button_pressed() -> void:
	if updating_SFX_controls:
		return
	
	updating_SFX_controls = true
	
	if SFX_texture_button.button_pressed:
		# Muted
		SFX_volume.value = 0
	else:
		# Unmuted — restore previous volume
		SFX_volume.value = last_SFX_volume_before_mute
	
	updating_SFX_controls = false

func _on_start_pressed() -> void:
	save_file()
	AnimationTranstion.transition_to_scene("res://Main Scenes/Game_Scene.tscn")

func _on_exit_pressed() -> void:
	save_file()
	get_tree().quit()

func _on_settings_pressed() -> void:
	main.visible = false
	settings.visible = true

func _on_donate_pressed() -> void:
	OS.shell_open("https://streamlabs.com/astronial_gaming/tip")

func _on_back_pressed() -> void:
	settings.visible = false
	main.visible = true

func _on_backLeader_pressed() -> void:
	leader_board.visible = false
	main.visible = true

func _on_leaderboard_button_pressed() -> void:
	leader_board.visible = true
	main.visible = false

func _on_game_jam_pressed() -> void:
	main.visible = false
	game_jam.visible = true

func _on_GameBack_pressed() -> void:
	main.visible = true
	game_jam.visible = false

func _on_TutorialBack_pressed() -> void:
	main.visible = true
	tutorial.visible = false

func _on_tutorial_pressed() -> void:
	main.visible = false
	tutorial.visible = true

func _on_next_pressed() -> void:
	page_number = clamp((page_number + 1), 1, 5)
	print(page_number)

func _on_backButton_pressed() -> void:
	page_number = clamp((page_number - 1), 1, 5)
	print(page_number)
