extends Control

@onready var panel_container: PanelContainer = $CanvasLayer/PanelContainer
@onready var button: Button = $CanvasLayer/Button

var distractions = {"dist1": preload("res://Distractions/ADS/apples_ad.tscn"),
					"dist2": preload("res://Distractions/ADS/Pizza_ad.tscn"),
					"dist3": preload("res://Distractions/ADS/mask_ad.tscn"),
					"dist4": preload("res://Distractions/ADS/Moon_ad.tscn"),
					"dist5": preload("res://Distractions/ADS/Spider_ad.tscn"),
					"dist6": preload("res://Distractions/ADS/petRock_ad.tscn"),
					"dist7": preload("res://Distractions/ADS/water_ad.tscn")}

func _ready() -> void:
	set_random_position_on_screen()
	button.text = "Click Here For " + str(randi_range(100, 5000)) +" coins"

func set_random_position_on_screen():
	var viewport_size = get_viewport_rect().size
	var random_pos = Vector2(
		randf_range(0, viewport_size.x),
		randf_range(0, viewport_size.y)
	)
	button.position = random_pos

func spawn_random_distraction():
	if distractions.is_empty():
		print("No distractions found, bruh 💀")
		return

	var random_scene = distractions.values().pick_random()
	var instance = random_scene.instantiate()
	add_child(instance)

func _on_button_pressed() -> void:
	spawn_random_distraction()

func _on_timer_timeout() -> void:
	queue_free()
