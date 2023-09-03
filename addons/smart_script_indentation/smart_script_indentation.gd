@tool
extends EditorPlugin


### Objects ###

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
var enter_count: int
var find_next_func: bool


func _init() -> void:
	action_timer = Timer.new() as Timer
	action_timer.one_shot = true
	add_child(action_timer)


func _enter_tree() -> void:
	action_timer.timeout.connect(_on_action_timer_timeout)


func _process(delta: float) -> void:
	editor_interface = get_editor_interface()
	editor_settings = editor_interface.get_editor_settings()
	editor_settings.set_setting("Editor Plugins/Scripts/Smart Indent/Action Timeout", 1)
	editor_settings.set_setting("Editor Plugins/Scripts/Smart Indent/Enter Count Threshold", 3)
	editor_settings.set_setting("Editor Plugins/Scripts/Smart Indent/Insert Line Spacing Hotkey", false)
	editor_settings.set_setting("Editor Plugins/Scripts/Smart Indent/Find Next Func", true)
	editor_settings.set_setting("Editor Plugins/Scripts/Smart Indent/Find Next Func Threshold", 3)
	editor_settings.add_property_info(action_timeout_setting)
	editor_settings.add_property_info(enter_count_threshold_setting)
	editor_settings.add_property_info(insert_line_spacing_hotkey_setting)
	editor_settings.add_property_info(find_next_func_setting)
	editor_settings.add_property_info(find_next_func_threshold_setting)
	editor_settings.settings_changed.connect(_on_editor_settings_changed)
	action_timer.wait_time = editor_settings.get_setting("Editor Plugins/Scripts/Smart Indent/Action Timeout")
	script_editor = editor_interface.get_script_editor()
	script_editor.editor_script_changed.connect(_on_editor_script_changed)
	script_code = script_editor.get_current_editor().get_base_editor() as CodeEdit
	script_code.text_changed.connect(_on_text_changed)
	set_process(false)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_ENTER and Input.is_key_pressed(KEY_SHIFT):
			if find_next_func:
				var caret_position: int = script_code.get_caret_line()
				for next_line in range(1, 4):
					var line_func = script_code.get_line(caret_position + next_line).begins_with("func")
					var line_static_func = script_code.get_line(caret_position + next_line).begins_with("static func")
					if line_func or line_static_func:
						if next_line == 1:
							script_code.insert_line_at(caret_position, "")
							script_code.insert_line_at(caret_position, "")
							script_code.insert_line_at(caret_position, "")
							script_code.insert_line_at(caret_position, "")
							script_code.set_caret_line(caret_position + 2)
						elif next_line == 2:
							script_code.insert_line_at(caret_position, "")
							script_code.insert_line_at(caret_position, "")
							script_code.insert_line_at(caret_position, "")
							script_code.set_caret_line(caret_position + 2)
						elif next_line == 3:
							script_code.insert_line_at(caret_position, "")
							script_code.insert_line_at(caret_position, "")
							script_code.set_caret_line(caret_position + 2)
			else:
				script_code.set_line(script_code.get_caret_line(), "")
			action_timer.stop()
			enter_count = 0


func _exit_tree() -> void:
	editor_settings.settings_changed.disconnect(_on_editor_settings_changed)
	editor_settings.erase("Editor Plugins/Scripts/Smart Indent/Action Timeout")
	editor_settings.erase("Editor Plugins/Scripts/Smart Indent/Enter Count Threshold")
	editor_settings.erase("Editor Plugins/Scripts/Smart Indent/Insert Line Spacing Hotkey")
	editor_settings.erase("Editor Plugins/Scripts/Smart Indent/Find_Next_Func")
	editor_settings.erase("Editor Plugins/Scripts/Smart Indent/Find_Next_Func_Threshold")
	script_editor.editor_script_changed.disconnect(_on_editor_script_changed)
	script_code.text_changed.disconnect(_on_text_changed)
	action_timer.timeout.disconnect(_on_action_timer_timeout)


func _on_action_timer_timeout() -> void:
	enter_count = 0


func _on_editor_settings_changed() -> void:
	action_timer.stop()
	enter_count = 0
	action_timer.wait_time = editor_settings.get_setting("Editor Plugins/Scripts/Smart Indent/Action Timeout")
	find_next_func = editor_settings.get_setting("Editor Plugins/Scripts/Smart Indent/Find_Next_Func")


func _on_editor_script_changed(_script: Script) -> void:
	script_code.text_changed.disconnect(_on_text_changed)
	script_code = script_editor.get_current_editor().get_base_editor() as CodeEdit
	script_code.text_changed.connect(_on_text_changed)
	action_timer.stop()
	enter_count = 0


func _on_text_changed() -> void:
	if Input.is_key_pressed(KEY_ENTER):
		enter_count += 1
		if enter_count == 1:
			action_timer.start()
		elif enter_count >= 3:
			if find_next_func:
				var caret_position: int = script_code.get_caret_line()
				for next_line in range(1, 4):
					var line_func = script_code.get_line(caret_position + next_line).begins_with("func")
					var line_static_func = script_code.get_line(caret_position + next_line).begins_with("static func")
					if line_func or line_static_func:
						if next_line == 1:
							script_code.insert_line_at(caret_position, "")
							script_code.insert_line_at(caret_position, "")
							script_code.insert_line_at(caret_position, "")
							script_code.insert_line_at(caret_position, "")
							script_code.set_caret_line(caret_position + 2)
						elif next_line == 2:
							script_code.insert_line_at(caret_position, "")
							script_code.insert_line_at(caret_position, "")
							script_code.insert_line_at(caret_position, "")
							script_code.set_caret_line(caret_position + 2)
						elif next_line == 3:
							script_code.insert_line_at(caret_position, "")
							script_code.insert_line_at(caret_position, "")
							script_code.set_caret_line(caret_position + 2)
			else:
				script_code.set_line(script_code.get_caret_line(), "")
			action_timer.stop()
			enter_count = 0
