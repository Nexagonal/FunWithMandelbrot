## An implementation of a Mandelbrot set visualization.
## It can be dragged around and zoomed into, but is limited to the GPU's float precision.
##
## Use the mouse wheel to zoom in and out, or hold the right mouse button to zoom in smoothly.
##
## The main calculations are done in a shader; this script just handles panning and zooming.



extends ColorRect

@onready var x_mult: CoolSlider = $"../Control/VBoxContainer/x_mult"
@onready var y_mult: CoolSlider = $"../Control/VBoxContainer/y_mult"
@onready var threshold: CoolSlider = $"../Control/VBoxContainer/threshold"
@onready var strange_mult: CoolSlider = $"../Control/VBoxContainer/strange_mult"
@onready var a_var: CoolSlider = $"../Control/VBoxContainer/a_var"
@onready var b_var: CoolSlider = $"../Control/VBoxContainer/b_var"
@onready var c_var: CoolSlider = $"../Control/VBoxContainer/c_var"
@onready var d_var: CoolSlider = $"../Control/VBoxContainer/d_var"
@onready var e_var: CoolSlider = $"../Control/VBoxContainer/e_var"

var x_mult_value : float
var y_mult_value : float
var threshold_value : float
var strange_mult_value : float
var a_var_value : float
var b_var_value : float
var c_var_value : float
var d_var_value : float
var e_var_value : float

# The minimum zoom level.
const min_zoom: float = 0.5

# The maximum zoom level.
const max_zoom: float = INF


# The shader material.
@onready var shader_material = material as ShaderMaterial


# The coordinate represented by the center of the screen.
var center: Vector2 = Vector2.ZERO

# The distance between the center and the edges of the screen at default zoom.
var margin: Vector2 = Vector2(2.5, 1.5)

# The current zoom level.
var zoom: float = 1.0
var cur_zoom : float = 1.0
var cur_center

var disable_input : bool = false

## How much the scale grows with each zoom step using the mouse wheel.
const fast_zoom_factor: float = 1.1

## How much the scale grows with each zoom step using the mouse button.
const slow_zoom_factor: float = 1.025

## Whether the view si currently being dragged.
var dragging: bool = false



func _ready() -> void:

	# initialize shader parameters
	_zoom(0)
	shader_material.set_shader_parameter("center", center)
	shader_material.set_shader_parameter("palette", $GradientSprite.texture)
	cur_center = center



func _process(_delta: float) -> void:

	if Input.is_action_just_pressed("ui_cancel"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	if Input.is_action_just_pressed("wheel_up") and !disable_input:
		_zoom(fast_zoom_factor)

	if Input.is_action_just_pressed("wheel_down") and !disable_input:
		_zoom(1.0 / fast_zoom_factor)

	if Input.is_action_just_pressed("left_click") and !disable_input:
		dragging = true

	if Input.is_action_just_released("left_click"):
		dragging = false

	if Input.is_action_pressed("right_click") and !disable_input:
		_zoom(slow_zoom_factor)
	
	if Input.is_action_pressed("fullscreen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	shader_material.set_shader_parameter("x_mult", x_mult_value)
	shader_material.set_shader_parameter("y_mult", y_mult_value)
	shader_material.set_shader_parameter("threshold", threshold_value)
	shader_material.set_shader_parameter("strange_mult", strange_mult_value)
	shader_material.set_shader_parameter("a_var", a_var_value)
	shader_material.set_shader_parameter("b_var", b_var_value)
	shader_material.set_shader_parameter("c_var", c_var_value)
	shader_material.set_shader_parameter("d_var", d_var_value)
	shader_material.set_shader_parameter("e_var", e_var_value)
	



func _input(event: InputEvent) -> void:

	if event is InputEventMouseMotion and !disable_input:

		if not dragging:
			return

		# handle dragging
		# (convert the mouse distance to "math coordinates"
		# and move the center point by that amount)
		var distance: Vector2 = event.relative
		distance.x = distance.x * 2 * margin.x / (get_viewport().size.x * zoom)
		distance.y = distance.y * 2 * margin.y / (get_viewport().size.y * zoom)
		center -= distance
		shader_material.set_shader_parameter("center", cur_center)

func _physics_process(delta: float) -> void:
	shader_material.set_shader_parameter("zoom", cur_zoom)
	shader_material.set_shader_parameter("center", cur_center)
	cur_zoom = lerpf(cur_zoom, zoom, delta * 5)
	cur_center = lerp(cur_center, center, delta * 5)
	x_mult_value = lerpf(x_mult_value, x_mult.value, delta * 5)
	y_mult_value = lerpf(y_mult_value, y_mult.value, delta * 5)
	threshold_value = lerpf(threshold_value, threshold.value, delta * 5)
	strange_mult_value = lerpf(strange_mult_value, strange_mult.value, delta * 5)
	a_var_value = lerpf(a_var_value, a_var.value, delta * 5)
	b_var_value = lerpf(b_var_value, b_var.value, delta * 5)
	c_var_value = lerpf(c_var_value, c_var.value, delta * 5)
	d_var_value = lerpf(d_var_value, d_var.value, delta * 5)
	e_var_value = lerpf(e_var_value, e_var.value, delta * 5)
	
## Zooms in or out.
##
func _zoom(factor: float = fast_zoom_factor) -> void:

	# preserve current mouse cursor position
	# (it might change after zooming because the mouse cursor might end up
	# on a different point in the image)
	var old_mouse_pos = _math_coords(get_local_mouse_position())

	# change the zoom and update the shader parameter
	zoom *= factor
	zoom = clampf(zoom, min_zoom, max_zoom)

	# determine where the mouse cursor ended up after zooming
	# and move the image so that the mouse cursor is on the same point as before
	var new_mouse_pos = _math_coords(get_local_mouse_position())
	var diff = new_mouse_pos - old_mouse_pos
	center -= diff



## Converts a vector describing screen coordinates (pixels from 0 to screen width / height)
## to a point in the Mandelbrot set's coordinate system,
## depending on the current center point and zoom.
##
func _math_coords(pos: Vector2) -> Vector2:

	var new_x: float = lerp(center.x - margin.x / zoom, center.x + margin.x / zoom, pos.x / get_viewport().size.x)
	var new_y: float = lerp(center.y - margin.y / zoom, center.y + margin.y / zoom, pos.y / get_viewport().size.y)

	return Vector2(new_x, new_y)


func _on_control_mouse_entered() -> void:
	disable_input = true
	
func _on_control_mouse_exited() -> void:
	disable_input = false
