@tool
extends EditorPlugin


### Nodes ###

var editor_interface: EditorInterface
var editor_settings: EditorSettings
var script_editor: ScriptEditor
var script_code: CodeEdit
var action_timer: Timer


### Settings ###

const action_timeout_setting = {
		"name": "Editor Plugins/Scripts/Smart Indent/Action Timeout",
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0, 3"
	}
const enter_count_threshold_setting = {
		"name": "Editor Plugins/Scripts/Smart Indent/Enter Count Threshold",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "1,4,1"
	}
const insert_line_spacing_hotkey_setting = {
		"name": "Editor Plugins/Scripts/Smart Indent/Insert Line Spacing Hotkey",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "PROPERTY_USAGE_CHECKABLE"
	}
const find_next_func_setting = {
		"name": "Editor Plugins/Scripts/Smart Indent/Find Next Func",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "PROPERTY_USAGE_CHECKABLE"
	}
const find_next_func_threshold_setting = {
		"name": "Editor Plugins/Scripts/Smart Indent/Find Next Func Threshold",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "1,4,1"
	}
var enter_count_threshold: int
var hotkey: bool
var find_next_func: bool


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


func _process(delta: float) -> void:
	editor_interface = get_editor_interface()
	editor_settings = editor_interface.get_editor_settings()
	editor_settings.set_setting("Editor Plugins/Scripts/Smart Indent/Action Timeout", 1)
	editor_settings.set_setting("Editor Plugins/Scripts/Smart Indent/Enter Count Threshold", 3)
	editor_settings.set_setting("Editor Plugins/Scripts/Smart Indent/Insert Line Spacing Hotkey", true) # Default: false
	editor_settings.set_setting("Editor Plugins/Scripts/Smart Indent/Find Next Func", true)
	editor_settings.set_setting("Editor Plugins/Scripts/Smart Indent/Find Next Func Threshold", 3)
	editor_settings.add_property_info(action_timeout_setting)
	editor_settings.add_property_info(enter_count_threshold_setting)
	editor_settings.add_property_info(insert_line_spacing_hotkey_setting)
	editor_settings.add_property_info(find_next_func_setting)
	editor_settings.add_property_info(find_next_func_threshold_setting)
	editor_settings.settings_changed.connect(_on_editor_settings_changed)
	action_timer.wait_time = editor_settings.get_setting("Editor Plugins/Scripts/Smart Indent/Action Timeout")
	enter_count_threshold = editor_settings.get_setting("Editor Plugins/Scripts/Smart Indent/Enter Count Threshold")
	hotkey = editor_settings.get_setting("Editor Plugins/Scripts/Smart Indent/Insert Line Spacing Hotkey")
	find_next_func = editor_settings.get_setting("Editor Plugins/Scripts/Smart Indent/Find Next Func")
	script_editor = editor_interface.get_script_editor()
	script_editor.editor_script_changed.connect(_on_editor_script_changed)
	script_code = script_editor.get_current_editor().get_base_editor() as CodeEdit
	script_code.text_changed.connect(_on_script_code_text_changed)
	set_process(false)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if hotkey and event.is_pressed() and event.keycode == KEY_ENTER and Input.is_key_pressed(KEY_SHIFT):
			var caret_line: int = script_code.get_caret_line()
			for lines_to_match in enter_count_threshold + 1:
				for syntax in match_syntax:
					if find_next_func and script_code.get_line(caret_line + lines_to_match).begins_with(syntax):
						if lines_to_match == 0:
							for line_space in enter_count_threshold - 1:
								script_code.insert_line_at(caret_line, "")
							for line_space in enter_count_threshold:
								script_code.insert_line_at(caret_line, "")
							script_code.set_caret_line(caret_line - enter_count_threshold)
							reset_temp_data()
							return
						for line_space in enter_count_threshold - lines_to_match:
							script_code.insert_line_at(caret_line, "")
						for line_space in enter_count_threshold - lines_to_match:
							script_code.insert_line_at(caret_line + 1, "")
						script_code.set_line(caret_line, "")
						reset_temp_data()
						return
			print("NO FUNC")
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
			reset_temp_data()
			return
#			var caret_line: int = script_code.get_caret_line()
#			for lines_to_match in enter_count_threshold + 1:
#				for syntax in match_syntax:
#					if find_next_func and script_code.get_line(caret_line + lines_to_match).begins_with(syntax):
#						if lines_to_match == 0:
#							script_code.insert_line_at(caret_line, "")
#							script_code.insert_line_at(caret_line, "")
#							script_code.insert_line_at(caret_line, "")
#							script_code.insert_line_at(caret_line, "")
#							script_code.insert_line_at(caret_line, "")
#							script_code.set_caret_line(caret_line + 2)
#						elif lines_to_match == 1:
#							script_code.insert_line_at(caret_line + 1, "")
#							script_code.insert_line_at(caret_line + 1, "")
#							script_code.insert_line_at(caret_line + 1, "")
#							script_code.insert_line_at(caret_line + 1, "")
#							script_code.set_caret_line(caret_line + 2)
#						elif lines_to_match == 2:
#							script_code.insert_line_at(caret_line + 1, "")
#							script_code.insert_line_at(caret_line + 1, "")
#							script_code.insert_line_at(caret_line + 1, "")
#							script_code.set_caret_line(caret_line + 2)
#						elif lines_to_match == 3:
#							script_code.insert_line_at(caret_line + 1, "")
#							script_code.insert_line_at(caret_line + 1, "")
#							script_code.set_caret_line(caret_line + 2)
#					reset_temp_data()
#					return

func _exit_tree() -> void:
	editor_settings.settings_changed.disconnect(_on_editor_settings_changed)
	editor_settings.erase("Editor Plugins/Scripts/Smart Indent/Action Timeout")
	editor_settings.erase("Editor Plugins/Scripts/Smart Indent/Enter Count Threshold")
	editor_settings.erase("Editor Plugins/Scripts/Smart Indent/Insert Line Spacing Hotkey")
	editor_settings.erase("Editor Plugins/Scripts/Smart Indent/Find Next Func")
	editor_settings.erase("Editor Plugins/Scripts/Smart Indent/Find Next Func Threshold")
	script_editor.editor_script_changed.disconnect(_on_editor_script_changed)
	script_code.text_changed.disconnect(_on_script_code_text_changed)
	action_timer.timeout.disconnect(_on_action_timer_timeout)


func _on_action_timer_timeout() -> void:
	enter_count = 0


func _on_editor_settings_changed() -> void:
	reset_temp_data()
	action_timer.wait_time = editor_settings.get_setting("Editor Plugins/Scripts/Smart Indent/Action Timeout")
	enter_count_threshold = editor_settings.get_setting("Editor Plugins/Scripts/Smart Indent/Enter Count Threshold")
	hotkey = editor_settings.get_setting("Editor Plugins/Scripts/Smart Indent/Insert Line Spacing Hotkey")
	find_next_func = editor_settings.get_setting("Editor Plugins/Scripts/Smart Indent/Find Next Func")


func _on_editor_script_changed(_script: Script) -> void:
	script_code.text_changed.disconnect(_on_script_code_text_changed)
	script_code = script_editor.get_current_editor().get_base_editor() as CodeEdit
	script_code.text_changed.connect(_on_script_code_text_changed)
	reset_temp_data()


func _on_script_code_text_changed() -> void:
	if Input.is_key_pressed(KEY_ENTER):
		enter_count += 1
		if enter_count == 1:
			action_timer.start()
		elif enter_count == enter_count_threshold:
			var caret_line: int = script_code.get_caret_line()
			for lines_to_match in enter_count_threshold + 1:
				for syntax in match_syntax:
					if find_next_func and script_code.get_line(caret_line + lines_to_match).begins_with(syntax):
						if lines_to_match == 0:
							for line_space in enter_count_threshold - 1:
								script_code.insert_line_at(caret_line, "")
							script_code.set_caret_line(caret_line - 1)
							reset_temp_data()
							return
						for line_space in enter_count_threshold - lines_to_match:
							script_code.insert_line_at(caret_line + 1, "")
						script_code.set_line(caret_line, "")
						reset_temp_data()
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
			reset_temp_data()
			return


func reset_temp_data() -> void:
	action_timer.stop()
	enter_count = 0
