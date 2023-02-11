extends Node

signal gamepad_connected(device_id)
signal gamepad_disconnected(device_id)

var registered_gamepads: Dictionary = {}

func _ready():
	Input.connect("joy_connection_changed", self, "_gamepad_connection_changed")

func register_gamepad(device_id: int):
	registered_gamepads[device_id] = true
	for a in InputMap.get_actions():
		var any_device_action: String = a as String
		var this_device_action: String = any_device_action.replace("DEVICE", str(device_id))
		if any_device_action.ends_with("DEVICE"):
			for e in InputMap.get_action_list(any_device_action):
				var template_event: InputEvent = e as InputEvent
				var device_event := template_event.duplicate()
				device_event.device = device_id
				InputMap.add_action(this_device_action)
				InputMap.action_add_event(this_device_action, device_event)
				InputMap.action_add_event(any_device_action, device_event)

func _input(event: InputEvent) -> void:
	if not (event is InputEventJoypadButton):
		return
	if registered_gamepads.has(event.device):
		return
	print(event.device)

func _gamepad_connection_changed(id: int, connected: bool) -> void:
	if connected:
		print("gamepad connected: " + str(id))
		emit_signal("gamepad_connected", id)
	else:
		print("gamepad disconnected: " + str(id))
		emit_signal("gamepad_disconnected", id)
