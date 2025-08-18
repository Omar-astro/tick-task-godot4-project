extends Control

#region vars
var coins :int # <- temp coins
var last_coin_amount :int = 20
var timer :float = 20.0 # <- default time
var time_before_complete :float

var task_number := 1 # <- task number in scene
var current_upgrade_level := 0 # <- task upgrade level
const base_upgrade_cost := 40
var upgrade_cost : int # <- calculated per task + upgrade

var current_extend_time_level := 0 # <- extend time level
const base_extend_cost := 35 # <- base extend time cost
var extend_cost : int # <- calculated per task + upgrade

const base_coin_gained := 20 # <- amount of coins gained depend on task only
var coins_earned :int # <- value after calculating

var current_freeze_time_value := 50 # <- freeze time
var freeze_time_value :int # <- depends on task level only

var base_auto_bot_value := 300
var auto_bot_value :int

var remaining_time := 0.0
var remaining_freeze_time := 0.0
var paused := false
var Task_Name := "Battery Charge"   ##CHANGE THIS EVERY TASK------------------------
var temp1 := true
var max_reached := false

@onready var timer_node: Timer = $"../Timer"
@onready var freeze_time: Timer = $"../freeze time"
@onready var display_time: Label = $"../CanvasLayer/Control/task/UI/HBoxContainer/Time"
@onready var task_node: Control = $"../CanvasLayer/Control/task"
@onready var expand_cost_label: Label = $"../CanvasLayer/Control/upgrades/HBoxContainer/VBoxContainer/Container/expand_cost"
@onready var upgrade_cost_label: Label = $"../CanvasLayer/Control/upgrades/HBoxContainer/VBoxContainer/HBoxContainer/upgrade_cost"
@onready var freeze_cost_label: Label = $"../CanvasLayer/Control/upgrades/HBoxContainer/VBoxContainer2/HBoxContainer/freeze_cost"
@onready var coin_time: Label = $"../CanvasLayer/Control/task/UI/HBoxContainer/coin time"
@onready var bot_cost_label: Label = $"../CanvasLayer/Control/upgrades/HBoxContainer/VBoxContainer2/HBoxContainer2/bot_cost"
@onready var GlobalScene: Node
@onready var GlobalScore: Node
@onready var lever_pull: Node2D = $".."

#endregion

func _ready() -> void:
	GlobalScene = get_tree().root.get_node("Main/GlobalScene")
	GlobalScore = get_tree().root.get_node("Main/Score")
	#coins = GlobalScene.coins
	timer = timer_node.wait_time
	timer_node.start()
	update_cost()

func pause_timer():
	if not paused:
		remaining_time = timer_node.time_left
		timer_node.stop()
		paused = true

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

func update_cost():
	#print("updated")
	upgrade_cost = (base_upgrade_cost * (1 + 0.6 * current_upgrade_level)) * task_number
	upgrade_cost_label.text = "MAX" if current_upgrade_level >= 4 else str(format_number_short(upgrade_cost))
	
	extend_cost = (base_extend_cost + (current_extend_time_level * 15)) * task_number
	expand_cost_label.text = str(format_number_short(extend_cost))
	
	freeze_time_value = 40 + (task_number * 10)
	freeze_cost_label.text = str(format_number_short(freeze_time_value))
	
	auto_bot_value = base_auto_bot_value * pow(1.4, task_number - 1)
	bot_cost_label.text = str(format_number_short(auto_bot_value))

func upgrade_time():
	timer += 10

func add_coins():
	#print(time_before_complete, " ", (timer_node.wait_time * 0.70))
	#print("added")
	if time_before_complete < (timer_node.wait_time * 0.70):
		var coins_gained = base_coin_gained * (1.5 + 0.3 * (task_number - 1))
		GlobalScene.coins += coins_gained
		GlobalScore.Money_gained += coins_gained
		GlobalScore.No_of_tasks_done += 1
		#print("gained")

func resume_timer():
	if paused:
		timer_node.start(remaining_time)
		paused = false

func freeze_timer():
	pause_timer()
	remaining_freeze_time = freeze_time.time_left
	freeze_time.stop()
	freeze_time.start(remaining_freeze_time + 10.0)

func time_managment():
	display_time.text = str("%.1f" % timer_node.time_left) if not paused else str("%.1f" % remaining_time)

func Task_lost():
	GlobalScore.Lives -= 1
	GlobalScore.Tasks_lost_on.append(Task_Name)

func _process(delta: float) -> void:
	time_managment()
	#coin_task_mangment()
	
	if current_upgrade_level >= 4:
		max_reached = true
	
	current_upgrade_level = task_node.task_level-1
	
	if timer_node.time_left < (timer_node.wait_time-1):
		time_before_complete = timer_node.time_left
	
	
	
	coin_time.text = str("%.1f" % (timer_node.wait_time * 0.70))
	#print(current_upgrade_level, " | ", upgrade_cost)
	#print("coins: ", coins)
	#$"../temp UI/HBoxContainer/Label".text = str(coins)

func _on_freeze_time_timeout() -> void:
	resume_timer()

func _on_task_lever_task_done() -> void:
	remaining_time = timer
	timer_node.wait_time = timer
	timer_node.start()

func _on_timer_timeout() -> void:
	Task_lost()
