extends Camera2D

var is_dragging =false
var drag_start_position = Vector2.ZERO

func _ready():
	# get VisualMap node
	var map = $"../VisualMap"
	
	# get viewport size
	var viewport_rect = get_viewport_rect()
	
	# get original size of map
	var map_texture = map.texture
	
	# calculate size of map at current scale
	var map_size = map_texture.get_size() * map.scale
	
	# get global position of sprite
	var map_global_position = map.global_position
	
	# calculate top-left corner
	var map_top_left = map_global_position - map_size / 2.0
	
	# adjuct viewport for camera zoom level
	var viewport_zoomed = viewport_rect.size / 2.0 / zoom
	
	# set limits
	limit_left = map_top_left.x + viewport_zoomed.x
	limit_top = map_top_left.y + viewport_zoomed.y
	limit_right = map_top_left.x + map_size.x - viewport_zoomed.x
	limit_bottom = map_top_left.y + map_size.y - viewport_zoomed.y

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
