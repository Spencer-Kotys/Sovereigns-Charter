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
	# Start dragging when the left mouse button is pressed
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_dragging = true
			drag_start_position = get_global_mouse_position() - self.position
		else:
			is_dragging = false
			
	# While dragging, move the camera
	if event is InputEventMouseMotion and is_dragging:
		self.position = get_global_mouse_position() - drag_start_position
		
		# define min and max camera positions
		var min_x = MAP_WIDTH / 3.0
		var max_x = MAP_WIDTH / 1.5
		var min_y = MAP_HEIGHT / 3.0
		var max_y = MAP_HEIGHT / 1.5
		
		# clamp camera to min and max positions
		self.position.x = clamp(self.position.x, min_x, max_x)
		self.position.y = clamp(self.position.y, min_y, max_y)
