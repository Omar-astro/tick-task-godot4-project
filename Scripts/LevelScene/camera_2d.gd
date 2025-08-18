extends Camera2D

@export var base_camera_speed: float = 700.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.4
@export var max_zoom: float = 1.7

func _process(delta: float) -> void:
	# Zoom-aware movement speed
	var adjusted_speed = base_camera_speed / zoom.length()  # zoom.length() = sqrt(x^2 + y^2), nicely scales with zoom level

	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("Right"):
		input_vector.x += 1
	if Input.is_action_pressed("Left"):
		input_vector.x -= 1
	if Input.is_action_pressed("Down"):
		input_vector.y += 1
	if Input.is_action_pressed("Up"):
		input_vector.y -= 1

	position += input_vector.normalized() * adjusted_speed * delta

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom *= 1.0 - zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom *= 1.0 + zoom_speed

		# Clamp zoom to prevent insanity
		zoom.x = clamp(zoom.x, min_zoom, max_zoom)
		zoom.y = clamp(zoom.y, min_zoom, max_zoom)
