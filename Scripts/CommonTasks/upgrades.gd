extends Control



signal Task_upgrade
signal update_value

@onready var upgrade_1: Button = $"HBoxContainer/VBoxContainer/Container/Upgrade 1"
@onready var upgrade_2: Button = $"HBoxContainer/VBoxContainer2/HBoxContainer/Upgrade 2"
@onready var upgrade_3: Button = $"HBoxContainer/VBoxContainer/HBoxContainer/Upgrade 3"
@onready var upgrade_4: Button = $"HBoxContainer/VBoxContainer2/HBoxContainer2/Upgrade 4"
@onready var lever_pull: Node2D = $"../../.."
@onready var timer: Timer = $"../../../Timer"
@onready var freeze_time: Timer = $"../../../freeze time"
@onready var global: Control = $"../../../Global"
@onready var GlobalScore: Node
@onready var task: Control = $"../task"

func _ready() -> void:
	GlobalScore = get_tree().root.get_node("Main/Score")


func _process(delta: float) -> void:
	#print(lever_pull.window_open)
	
	
	
	if task.task_lost:
		upgrade_1.disabled = true
		upgrade_2.disabled = true
		upgrade_3.disabled = true
		upgrade_4.disabled = true
	
	if Input.is_action_just_pressed("3") and lever_pull.window_open:
		upgrade_3.emit_signal("pressed")
	elif Input.is_action_just_pressed("1") and lever_pull.window_open:
		upgrade_1.emit_signal("pressed")
	elif Input.is_action_just_pressed("2") and lever_pull.window_open:
		upgrade_2.emit_signal("pressed")
	elif Input.is_action_just_pressed("4") and lever_pull.window_open:
		upgrade_4.emit_signal("pressed")

func _on_level_increase_pressed() -> void:
	if global.GlobalScene.coins >= global.upgrade_cost and !global.max_reached:
		global.GlobalScene.coins -= global.upgrade_cost
		GlobalScore.Money_spent += global.upgrade_cost
		emit_signal("Task_upgrade")
		global.current_upgrade_level += 1
		emit_signal("update_value")
		$"../../../SFX/cash".play()
		GlobalScore.Number_of_upgrade_purchase += 1
	else:
		print("failed upgrade")
		$"../../../SFX/fail purchase".play()

func _on_upgrade_1_pressed() -> void:
	if global.GlobalScene.coins >= global.extend_cost:
		global.current_extend_time_level += 1
		global.GlobalScene.coins -= global.extend_cost
		GlobalScore.Money_spent += global.extend_cost
		global.upgrade_time()
		emit_signal("update_value")
		$"../../../SFX/cash".play()
		GlobalScore.Number_of_extend_purchase += 1
	else:
		print('failed extend')
		$"../../../SFX/fail purchase".play()

func _on_upgrade_2_pressed() -> void:
	if global.GlobalScene.coins >= global.freeze_time_value:
		global.GlobalScene.coins -= global.freeze_time_value
		GlobalScore.Money_spent += global.freeze_time_value
		global.freeze_timer()
		$"../../../SFX/ice crack".play()
		emit_signal("update_value")
		GlobalScore.Number_of_freeze_times += 1
	else:
		print('failed freeze')
		$"../../../SFX/fail purchase".play()

func _on_upgrade_4_pressed() -> void:
	#print('Auto-Bot active')
	if global.GlobalScene.coins >= global.auto_bot_value:
		global.GlobalScene.coins -= global.auto_bot_value
		GlobalScore.Money_spent += global.auto_bot_value
		upgrade_4.disabled = true
		$"../task/AnimatedSprite2D".visible = true
		$"../task".auto_bot = true
		$"../../../SFX/cash".play()
		emit_signal("update_value")
		GlobalScore.Number_of_autobots += 1
	else:
		print('failed freeze')
		$"../../../SFX/fail purchase".play()
