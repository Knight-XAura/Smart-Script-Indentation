extends Control


### Nodes ###

var script_code: CodeEdit
var action_timer: Timer

@onready var action_tiemout_slider: HSlider = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer1/ActionTiemout
@onready var enter_count_threshold_spinbox: SpinBox = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/EnterCountThreshold
@onready var insert_new_function_spacing_hotkey_checkbox: CheckBox = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/InsertNewFunctionSpacingHotkey
@onready var find_upcoming_function_checkbox: CheckBox = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/FindUpcomingFunction


### Settings ###

@export_range(2, 7, 1) var enter_count_threshold: int = 3
@export var insert_new_function_spacing_hotkey: bool = true
@export var find_upcoming_function: bool = true

@export_range(0.33, 5) var action_timeout: float = 1


### Variables ###

var enter_count: int
const match_syntax: Array[String] = ["func ", "static func "]


func _init() -> void:
	action_timer = Timer.new() as Timer
	action_timer.one_shot = true
	add_child(action_timer)
	action_timer.timeout.connect(_on_action_timer_timeout)


func _enter_tree() -> void:
	pass


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	action_timer.wait_time = action_timeout
	script_code = $VBoxContainer/CodeEdit as CodeEdit
	script_code.gui_input.connect(_on_script_code_gui_input)
	set_process(false)


func _exit_tree() -> void: # Clean disconnects may not be needed? Similar to missing timer.queue_free()? RefCounted?
	script_code.gui_input.disconnect(_on_script_code_gui_input)
	action_timer.timeout.disconnect(_on_action_timer_timeout)


func _on_action_timer_timeout() -> void:
	enter_count = 0


func reset_action_data() -> void:
	action_timer.stop()
	enter_count = 0


func _on_script_code_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if insert_new_function_spacing_hotkey and event.is_pressed() and event.keycode == KEY_ENTER and Input.is_key_pressed(KEY_SHIFT):
			hotkey_action()
		elif Input.is_key_pressed(KEY_ENTER):
			threshold_action()


func hotkey_action() -> void:
	reset_action_data()
	var caret_line: int = script_code.get_caret_line()
	if find_upcoming_function:
		for lines_to_match in enter_count_threshold + 1:
			for syntax in match_syntax:
				if script_code.get_line(caret_line + lines_to_match).begins_with(syntax):
					if lines_to_match == 0:
						for line_space in enter_count_threshold - 1:
							script_code.insert_line_at(caret_line, "")
						for line_space in enter_count_threshold:
							script_code.insert_line_at(caret_line, "")
						script_code.set_caret_line(caret_line + 2)
						return
					caret_line += 1
					for line_space in enter_count_threshold:
						script_code.insert_line_at(caret_line, "")
					script_code.set_caret_line(caret_line)
					for line_space in enter_count_threshold - 1:
						script_code.insert_line_at(caret_line, "")
					return
	var caret_position = script_code.get_caret_column()
	var line_length = script_code.get_line(caret_line).length()
	if caret_position != line_length:
		for needed_spacing in enter_count_threshold * 2 - 1:
			script_code.insert_line_at(caret_line, "")
		script_code.set_caret_line(caret_line + enter_count_threshold - 1)
	elif caret_position == line_length:
		for needed_spacing in enter_count_threshold * 2 - 1:
			script_code.insert_line_at(caret_line + 1, "")
		script_code.set_caret_line(caret_line + enter_count_threshold)


func threshold_action() -> void:
	enter_count += 1
	if enter_count == 1:
		action_timer.start()
	elif enter_count == enter_count_threshold:
		reset_action_data()
		var caret_line: int = script_code.get_caret_line()
		if find_upcoming_function:
			for lines_to_match in enter_count_threshold + 1:
				for syntax in match_syntax:
					if script_code.get_line(caret_line + lines_to_match).begins_with(syntax):
						if lines_to_match == 0:
							for line_space in enter_count_threshold - 1:
								script_code.insert_line_at(caret_line, "")
							script_code.set_caret_line(caret_line - 1)
							return
						for line_space in enter_count_threshold - lines_to_match:
							script_code.insert_line_at(caret_line + 1, "")
						script_code.set_line(caret_line, "")
						return
		var caret_position = script_code.get_caret_column()
		var line_length = script_code.get_line(caret_line).length()
		if caret_position != line_length:
			for needed_spacing in enter_count_threshold - 1:
				script_code.insert_line_at(caret_line, "")
			script_code.set_caret_line(caret_line - 1)
			script_code.set_line(caret_line - 1, "")
		elif caret_position == line_length:
			for needed_spacing in enter_count_threshold - 1:
				script_code.insert_line_at(caret_line + 1, "")
			script_code.set_line(caret_line, "")


func _on_action_tiemout_drag_ended(_value_changed: bool) -> void:
	action_timeout = action_tiemout_slider.value
	action_timer.wait_time = action_timeout


func _on_enter_count_threshold_value_changed(value: int) -> void:
	enter_count_threshold = value


func _on_insert_new_function_spacing_hotkey_toggled(button_pressed: bool) -> void:
	insert_new_function_spacing_hotkey = button_pressed


func _on_find_upcoming_function_toggled(button_pressed: bool) -> void:
	find_upcoming_function = button_pressed
