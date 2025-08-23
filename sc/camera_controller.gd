extends Camera2D

var is_dragging =false
var drag_start_position = Vector2.ZERO

func _ready():
	# wait for first frame to process
	await get_tree().process_frame
	set_camera_limits()

func set_camera_limits():
	# get VisualMap node
	var map = $"../VisualMap"
	
	# check if successful
	if not map:
		print("No map node found")
		return
	
	# get map texture (the actual png file)
	var map_texture = map.texture
	if not map_texture:
		print("No map assigned to node")
		return
	
	# get viewport size
	var viewport_rect = get_viewport_rect()
	
	# calculate size of map at current scale
	var map_size = map_texture.get_size() * map.scale
	
	# calculate top-left corner
	var map_top_left = map.global_position - map_size / 2.0
	
	# adjuct viewport for camera zoom level
	var viewport_zoomed = viewport_rect.size / 2.0 / zoom
	
	# horizontal limits
	# if wider then view, set limits
	if map_size.x > viewport_zoomed.x:
		var viewport_half_size_zoomed = viewport_rect.size / 2.0 / zoom
		limit_left = map_top_left.x + viewport_half_size_zoomed.x
		limit_right = map_top_left.x + map_size.x - viewport_half_size_zoomed.x
	# if map is narrower, center the camera horizontally and lock it to center
	else:
		var map_center_x = map.global_position.x
		limit_left = map_center_x
		limit_right = map_center_x
		self.position.x = map_center_x
	
	# vertical Limits
	# if map is taller than the view, set vertical limits
	if map_size.y > viewport_zoomed.y:
		var viewport_half_size_zoomed = viewport_rect.size / 2.0 / zoom
		limit_top = map_top_left.y + viewport_half_size_zoomed.y
		limit_bottom = map_top_left.y + map_size.y - viewport_half_size_zoomed.y
	# if map is shorter, center the camera vertically and lock it to center
	else:
		var map_center_y = map.global_position.y
		limit_top = map_center_y
		limit_bottom = map_center_y
		self.position.y = map_center_y


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
