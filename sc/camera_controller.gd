extends Camera2D

var is_dragging =false
var drag_start_position = Vector2.ZERO

func _unhandled_input(event):
	# Start dragging when the middle mouse button is pressed
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.is_pressed():
			is_dragging = true
			drag_start_position = get_global_mouse_position() - self.position
		else:
			is_dragging = false
			
	# While dragging, move the camera
	if event is InputEventMouseMotion and is_dragging:
		self.position = get_global_mouse_position() - drag_start_position
