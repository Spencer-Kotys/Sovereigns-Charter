extends Camera2D

var is_dragging =false
var drag_start_position = Vector2.ZERO

func _ready():
	# wait for first frame to process
	await get_tree().process_frame
	set_camera_limits()
	
	# --- SAFETY CHECK ---
	# Ensure the camera's starting position is within the calculated limits.
	position.x = clamp(position.x, limit_left, limit_right)
	position.y = clamp(position.y, limit_top, limit_bottom)

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
	
	# adjuct viewport for camera zoom level
	var viewport_zoomed = viewport_rect.size / zoom
	
		# --- FULL DEBUG OUTPUT ---
	print("--- MAP & VIEWPORT VALUES ---")
	print("Map Size (pixels): ", map_size)
	print("Map Top Left Position: ", map_top_left)
	print("Viewport Size (zoomed): ", viewport_zoomed)
	print("-----------------------------")
	
	# horizontal limits
	# if wider then view, set limits
	if map_size.x > viewport_zoomed.x:
		print("--- HORIZONTAL CALCULATION ---")
		var viewport_half_size_zoomed_x = viewport_rect.size.x / 2.0 / zoom.x
		
		var new_limit_left = map_top_left.x + viewport_half_size_zoomed_x
		var new_limit_right = map_top_left.x + map_size.x - viewport_half_size_zoomed_x
		
		print("map_top_left.x: ", map_top_left.x)
		print("map_size.x: ", map_size.x)
		print("viewport_half_size_zoomed.x: ", viewport_half_size_zoomed_x)
		print("FINAL limit_left: ", new_limit_left)
		print("FINAL limit_right: ", new_limit_right)
		
		limit_left = new_limit_left
		limit_right = new_limit_right
	# if map is narrower, center the camera horizontally and lock it to center
	else:
		print("Map is smaller than screen, centering horizontally.")
		var map_center_x = map_top_left.x + map_size.x / 2.0
		limit_left = map_center_x
		limit_right = map_center_x
		self.position.x = map_center_x
	
	# vertical Limits
	# if map is taller than the view, set vertical limits
	if map_size.y > viewport_zoomed.y:
		print("--- VERTICAL CALCULATION ---")
		var viewport_half_size_zoomed_y = viewport_rect.size.y / 2.0 / zoom.y

		var new_limit_top = map_top_left.y + viewport_half_size_zoomed_y
		var new_limit_bottom = map_top_left.y + map_size.y - viewport_half_size_zoomed_y

		print("map_top_left.y: ", map_top_left.y)
		print("map_size.y: ", map_size.y)
		print("viewport_half_size_zoomed.y: ", viewport_half_size_zoomed_y)
		print("FINAL limit_top: ", new_limit_top)
		print("FINAL limit_bottom: ", new_limit_bottom)

		limit_top = new_limit_top
		limit_bottom = new_limit_bottom
	# if map is shorter, center the camera vertically and lock it to center
	else:
		print("Map is smaller than screen, centering vertically.")
		var map_center_y = map_top_left.y + map_size.y / 2.0
		limit_top = map_center_y
		limit_bottom = map_center_y
		self.position.y = map_center_y

func _input(event):
	# Handle starting and stopping the drag
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = event.is_pressed()

	# Handle the camera movement itself
	if event is InputEventMouseMotion and is_dragging:
		# 'event.relative' is the distance the mouse moved since the last frame.
		# We move the camera in the opposite direction of the mouse drag.
		# This feels natural, like dragging a piece of paper.
		self.position -= event.relative
