class_name CoolSlider
extends HBoxContainer

var value : float
var og_value : float

@onready var h_slider: HSlider = $HSlider
@onready var button: Button = $Button

func _ready() -> void:
	og_value = h_slider.value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	value = h_slider.value
	if h_slider.value != og_value:
		button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		button.modulate = Color(1.0, 1.0, 1.0, 0.0)

func _on_button_pressed() -> void:
	h_slider.value = og_value
