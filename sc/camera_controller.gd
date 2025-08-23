extends Camera2D

# declare variables
var MAP_WIDTH
var MAP_HEIGHT

var is_dragging =false
var drag_start_position = Vector2.ZERO

func _ready():
	# get parent node (should be world map node)
	var world_map = get_parent()
	# get values of map size
	MAP_WIDTH = world_map.MAP_WIDTH
	MAP_HEIGHT = world_map.MAP_HEIGHT

func _unhandled_input(event):
	# Start dragging when the middle mouse button is pressed
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_dragging = true
			drag_start_position = get_global_mouse_position() - self.position
		else:
			is_dragging = false
			
	# While dragging, move the camera
	if event is InputEventMouseMotion and is_dragging:
		self.position = get_global_mouse_position() - drag_start_position
