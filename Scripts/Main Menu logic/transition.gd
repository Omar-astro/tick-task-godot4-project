extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var animation_name := "transition"

var _loaded_scene: PackedScene = null


func transition_to_scene(path: String) -> void:
	# Pre-request threaded load
	ResourceLoader.load_threaded_request(path)

	# Fade-out
	anim.play(animation_name)
	await anim.animation_finished

	# Wait until scene is loaded
	while ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_LOADED:
		await get_tree().process_frame

	# Instantiate via change_scene_to_packed()
	var packed = ResourceLoader.load_threaded_get(path)
	get_tree().change_scene_to_packed(packed)

	# Fade-in
	anim.play_backwards(animation_name)
	await anim.animation_finished
