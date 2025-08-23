extends Camera2D

var is_dragging =false
var drag_start_position = Vector2.ZERO
var zoom_factor = 1.1

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
	var map_top_left = map.global_position
	
	# adjust viewport for camera zoom level
	var viewport_zoomed = viewport_rect.size / zoom
	
	# horizontal limits
	# if viewport is less than 1/3 the map width, zoom out
	if viewport_zoomed.x * 3 < map_size.x:
		zoom /= zoom_factor
	# if wider then view, set limits to width of map
	if map_size.x > viewport_zoomed.x:
		limit_left = map_top_left.x
		limit_right = map_size.x
	# if map is narrower, center the camera horizontally, lock it to center, and zoom
	else:
		zoom *= zoom_factor
		var map_center_x = map_size.x
		limit_left = map_center_x
		limit_right = map_center_x
		self.position.x = map_center_x
	
	# vertical Limits
	# if viewport is less than 1/3 the map height, zoom out
	if viewport_zoomed.y * 3 < map_size.y:
		zoom /= zoom_factor
	# if map is taller than the view, set vertical limits to height of map
	if map_size.y > viewport_zoomed.y:
		limit_top = map_top_left.y
		limit_bottom = map_size.y
	# if map is shorter, center the camera vertically, lock it to center, and zoom
	else:
		zoom *= zoom_factor
		var map_center_y = map_top_left.y
		limit_top = map_center_y
		limit_bottom = map_center_y
		self.position.y = map_center_y

func _input(event):
	# handle starting and stopping the drag
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = event.is_pressed()

	# handle the camera movement itself
	if event is InputEventMouseMotion and is_dragging:
		# 'event.relative' is the distance the mouse moved since the last frame
		# move the camera in the opposite direction of the mouse drag
		self.position -= event.relative
		
	# handle zooming
	if event is InputEventMouseButton:
		# if mouse wheel up zoom out
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom /= zoom_factor
			pass
		# if mouse wheel down zoom in
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom *= zoom_factor
		
		set_camera_limits()
