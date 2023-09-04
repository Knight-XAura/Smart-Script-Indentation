extends Control


### Nodes ###

var script_code: CodeEdit
var action_timer: Timer


### Settings ###

@export_range(1, 4, 1) var new_line_count_threshold: int = 3
@export var hotkey: bool = true
@export var find_next_function: bool = true

@export_range(0, 3) var action_timeout: float = 1


### Variables ###

var new_line_count: int
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


func _process(delta: float) -> void:
	action_timer.wait_time = action_timeout
	script_code = $CodeEdit as CodeEdit
	script_code.gui_input.connect(_on_script_code_gui_input)
	set_process(false)


func _exit_tree() -> void: # Clean disconnects may not be needed? Similar to missing timer.queue_free()? RefCounted?
	script_code.gui_input.disconnect(_on_script_code_gui_input)
	action_timer.timeout.disconnect(_on_action_timer_timeout)


func _on_action_timer_timeout() -> void:
	new_line_count = 0


func reset_action_data() -> void:
	action_timer.stop()
	new_line_count = 0


func _on_script_code_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if hotkey and event.is_pressed() and event.keycode == KEY_ENTER and Input.is_key_pressed(KEY_SHIFT):
			reset_action_data()
			var caret_line: int = script_code.get_caret_line()
			if find_next_function:
				for lines_to_match in new_line_count_threshold + 1:
					for syntax in match_syntax:
						if script_code.get_line(caret_line + lines_to_match).begins_with(syntax):
							if lines_to_match == 0:
								for line_space in new_line_count_threshold - 1:
									script_code.insert_line_at(caret_line, "")
								for line_space in new_line_count_threshold:
									script_code.insert_line_at(caret_line, "")
								script_code.set_caret_line(caret_line + 2)
								return
							caret_line += 1
							for line_space in new_line_count_threshold:
								script_code.insert_line_at(caret_line, "")
							script_code.set_caret_line(caret_line)
							for line_space in new_line_count_threshold - 1:
								script_code.insert_line_at(caret_line, "")
							return
			var caret_position = script_code.get_caret_column()
			var line_length = script_code.get_line(caret_line).length()
			if caret_position != line_length:
				for needed_spacing in new_line_count_threshold * 2 - 1:
					script_code.insert_line_at(caret_line, "")
				script_code.set_caret_line(caret_line + new_line_count_threshold - 1)
			elif caret_position == line_length:
				for needed_spacing in new_line_count_threshold * 2 - 1:
					script_code.insert_line_at(caret_line + 1, "")
				script_code.set_caret_line(caret_line + new_line_count_threshold)
		elif Input.is_key_pressed(KEY_ENTER):
			new_line_count += 1
		if new_line_count == 1:
			action_timer.start()
		elif new_line_count == new_line_count_threshold:
			reset_action_data()
			var caret_line: int = script_code.get_caret_line()
			if find_next_function:
				for lines_to_match in new_line_count_threshold + 1:
					for syntax in match_syntax:
						if script_code.get_line(caret_line + lines_to_match).begins_with(syntax):
							if lines_to_match == 0:
								for line_space in new_line_count_threshold - 1:
									script_code.insert_line_at(caret_line, "")
								script_code.set_caret_line(caret_line - 1)
								return
							for line_space in new_line_count_threshold - lines_to_match:
								script_code.insert_line_at(caret_line + 1, "")
							script_code.set_line(caret_line, "")
							return
			var caret_position = script_code.get_caret_column()
			var line_length = script_code.get_line(caret_line).length()
			if caret_position != line_length:
				for needed_spacing in new_line_count_threshold - 1:
					script_code.insert_line_at(caret_line, "")
				script_code.set_caret_line(caret_line - 1)
				script_code.set_line(caret_line - 1, "")
			elif caret_position == line_length:
				for needed_spacing in new_line_count_threshold - 1:
					script_code.insert_line_at(caret_line + 1, "")
				script_code.set_line(caret_line, "")
