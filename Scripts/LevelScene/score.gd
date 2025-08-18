extends Node

var Number_of_upgrade_purchase := 0 #DONE
var Number_of_extend_purchase := 0 #DONE
var Number_of_freeze_times := 0 #DONE
var Number_of_autobots := 0 #DONE
var Money_spent := 0 #DONE
var Money_gained := 0 #DONE
var No_of_tasks_done := 0 #DONE
var No_of_distractions_ignored := 0 #DONE
var Time_spent_in_the_game := 0.0 # <- in the end #DONE
var Number_of_tasks_held := 1 # <- in the end #DONE
var No_of_coins_in_the_end := 0 # <- in the end #DONE
var Tasks_lost_on = [] # <- in the end #DONE

var TotalScore := 0.0 #Configure this in the end
#Total time Survived (in the end) - 1 pps(point per second)
#Number of tasks done - 100 ppt(point per task)
#coins left in the end (in the end) - 1 ppc
#No of autoBots (in the end) - 200 ppb


var Lives := 3
var temp1 := true
var temp2 := true
var temp3 := true

@onready var lives: HBoxContainer = $"../UI/Lives"
@onready var lose_sound_1: AudioStreamPlayer = $"../Sounds/Lose sound 1"
@onready var lose_sound_2: AudioStreamPlayer = $"../Sounds/Lose sound 2"
@onready var global_scene: Node = $"../GlobalScene"
@onready var task_spawner: Node = $"../Task Spawner"

#region labels
@onready var total_score_label: Label = $"../Lose Screen/PanelContainer/Total_score"
@onready var no_upgrade_label: Label = $"../Lose Screen/PanelContainer/ScrollContainer/VBoxContainer/No Upgrade"
@onready var no_extend_label: Label = $"../Lose Screen/PanelContainer/ScrollContainer/VBoxContainer/No extend"
@onready var no_of_freeze_label: Label = $"../Lose Screen/PanelContainer/ScrollContainer/VBoxContainer/No of freeze"
@onready var no_of_auto_bot_label: Label = $"../Lose Screen/PanelContainer/ScrollContainer/VBoxContainer/No of autoBot"
@onready var money_spent_label: Label = $"../Lose Screen/PanelContainer/ScrollContainer/VBoxContainer/money spent"
@onready var money_gained_label: Label = $"../Lose Screen/PanelContainer/ScrollContainer/VBoxContainer/money gained"
@onready var no_of_tasks_done_label: Label = $"../Lose Screen/PanelContainer/ScrollContainer/VBoxContainer/No of tasks done"
@onready var no_of_dist_label: Label = $"../Lose Screen/PanelContainer/ScrollContainer/VBoxContainer/No of dist"
@onready var no_of_tasks_held_label: Label = $"../Lose Screen/PanelContainer/ScrollContainer/VBoxContainer/no of tasks held"
@onready var no_of_coins_label: Label = $"../Lose Screen/PanelContainer/ScrollContainer/VBoxContainer/No of coins"
@onready var tasks_lost_on_label: Label = $"../Lose Screen/PanelContainer/ScrollContainer/VBoxContainer/tasks lost on"
@onready var total_time_label: Label = $"../Lose Screen/PanelContainer/ScrollContainer/VBoxContainer/Total Time"

#endregion


var duration := 3.0
var elapsed := 0.0
var start_scale := 1.0
var is_slowing := true

func transition_song(song1, song2):
	var music_1 = song1
	var music_2 = song2
	
	music_2.volume_db = -80  # Start muted
	music_2.play()
	
	var duration = 1.5  # Transition time in seconds
	var t = 0.0
	var step = 0.05
	
	while t < 1.0:
		await get_tree().create_timer(step).timeout
		t += step / duration
		var fade = lerp(-80, 0, t)
		music_1.volume_db = lerp(0, -80, t)
		music_2.volume_db = fade
	
	music_1.stop()
	music_1.volume_db = 0
	music_2.volume_db = 0

func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("Debug1"):
		#Lives -= 1
	
	if Lives == 2 and temp1:
		var heart:Sprite2D = lives.get_node("Heart3")
		heart.frame = 1

		transition_song($"../Sounds/BG music 1", $"../Sounds/BG music 2")
		temp1 = false
	elif Lives == 1 and temp2:
		var heart:Sprite2D = lives.get_node("Heart2")
		heart.frame = 1
		
		transition_song($"../Sounds/BG music 2", $"../Sounds/BG music 3")
		temp2 = false
	elif Lives == 0 and temp3:
		game_lost()

func total_score_calculations() -> void:
	TotalScore = \
		(Number_of_upgrade_purchase * 5) +\
		(Number_of_extend_purchase * 3) +\
		(Number_of_freeze_times * 2) +\
		(Number_of_autobots * 10) +\
		(No_of_tasks_done * 10) +\
		(No_of_distractions_ignored * 3) +\
		(Time_spent_in_the_game * 2) +\
		(No_of_coins_in_the_end / 5.0)

func final_scores():
	total_score_label.text = "Total score: " + "\t" + "\t" + str(TotalScore)
	no_upgrade_label.text = "Total score: " + "\t" + "\t" + str(Number_of_upgrade_purchase)
	no_extend_label.text = "Number of Times Extended: " + "\t" + "\t" + str(Number_of_extend_purchase)
	no_of_freeze_label.text = "Number of Times freezed: " + "\t" + "\t" + str(Number_of_freeze_times)
	no_of_auto_bot_label.text = "Number of AutoBots: " + "\t" + "\t" + str(Number_of_autobots)
	money_spent_label.text = "Money Spent: " + "\t" + "\t"+ str(Money_spent)
	money_gained_label.text = "Money Gained: " + "\t" + "\t"+ str(Money_gained)
	no_of_dist_label.text = "Number of distractions ignored: " + "\t" + "\t"+ str(No_of_distractions_ignored)
	total_time_label.text = "Total Time: " + "\t" + "\t"+ str(Time_spent_in_the_game)
	no_of_tasks_held_label.text = "Number of tasks held: " + "\t" + "\t"+ str(Number_of_tasks_held - 3)
	no_of_coins_label.text = "Number of Coins Left: " + "\t" + "\t"+ str(No_of_coins_in_the_end)
	tasks_lost_on_label.text = "Tasks Lost On: " + Tasks_lost_on[0] + " | " + Tasks_lost_on[1] + " | " + Tasks_lost_on[2]

func game_lost():
	print("--LOST GAME--")
	global_scene.on_shot_pause()
	Time_spent_in_the_game = global_scene.final_time
	No_of_distractions_ignored = task_spawner.no_of_distractions
	No_of_tasks_done = task_spawner.task_number
	No_of_coins_in_the_end = global_scene.coins
	total_score_calculations()
	final_scores()
	
	$"../Sounds/BG music 3".stop()
	var heart:Sprite2D = lives.get_node("Heart1")
	heart.frame = 1
	
	#Lost Screen
	lose_sound_1.play() if randi_range(0,10) <= 9 else lose_sound_2.play()
	for child in get_tree().current_scene.get_children():
		if child.is_in_group("Task"):
			child.queue_free()
			$"../UI".visible = false
			$"../Spawn task time".stop() 
			$"../Distraction time".stop()
			$"../DelayTime".start()
	temp3 = false

func _on_delay_time_timeout() -> void:
	$"../Lose Screen".visible = true


func _on_Restart_pressed() -> void:
	pass # Replace with function body.
