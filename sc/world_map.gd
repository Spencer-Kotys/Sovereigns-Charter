extends Node2D

@onready var visual_map_sprite: Sprite2D = $VisualMap
@onready var provinces_container = $Provinces
const GEOJSON_PATH = "res://resources/maps/Sea of Aerthos and Outlining Regions Cells 2025-08-21-19-15.geojson"

# var to store province data
var province_data = {}
var selected_province = null

func _ready():
	# for debugging
	provinces_container.visible = true
	
	load_provinces()
	draw_provinces()
	
func load_provinces():
	# open file and save data
	var file = FileAccess.open(GEOJSON_PATH, FileAccess.READ)
	if not file:
		push_error("Failed to open GeoJSON file at: %s" % GEOJSON_PATH)
		return
	var json_data = JSON.parse_string(file.get_as_text())
	file.close()
	
	# extract data from features array
	if json_data and json_data.has("features"):
		for feature in json_data.features:
			# get unique ID
			var province_id = feature.properties.id
			
			# store data
			province_data[province_id] = {
				"biome": feature.properties.biome,
				"type": feature.properties.type,
				"population": feature.properties.population,
				"state": feature.properties.state,
				"province": feature.properties.province,
				"culture": feature.properties.culture,
				"religion": feature.properties.religion,
				"neighbors": feature.properties.neighbors,
				"geometry": feature.geometry.coordinates[0]
			}

func draw_provinces():
	# for each province
	for id in province_data:
		var data = province_data[id]
		
		# area to detect input and collision, add unique names for scenetree
		#var province_area = Area2D.new()
		#province_area.name = "ProvinceArea_" + str(id)
		
		# province polygon 
		var province_polygon = Polygon2D.new()
		
		# metadata to connect province to area
		# province_area.set_meta("province_id", id)
		
		# new collision shape
		#var collision_polygon = CollisionPolygon2D.new()
		
		# convert JSON array points to vectors
		var polygon_points = PackedVector2Array()
		for point in data.geometry: # may need to change
			polygon_points.append(Vector2(point[0], point[1]))
		
		# enter province points into new polygon
		province_polygon.polygon = polygon_points
		#collision_polygon.polygon = polygon_points
		
		# connect event signals
		#province_area.input_event.connect(_on_province_input_event)
		
		# add collision to province area
		#province_area.add_child(collision_polygon)
		
		# add new province to container
		#provinces_container.add_child(province_area)
		
		# A semi-transparent white lets the main map show through.
		province_polygon.color = Color(1, 1, 1, 0.2)
		
		# Store metadata directly on the node. This is very useful!
		province_polygon.set_meta("province_id", id)
		# You can store more data here (population, culture, etc.)
		# province_nodes[province_id] = province_polygon
		
		# add polygon
		provinces_container.add_child(province_polygon)

# Use _unhandled_input to not intercept GUI events
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var clicked_province = get_province_at_position(event.position)
		
		# --- Highlighting Logic ---
		# First, reset the previously selected province (if any)
		if selected_province != null:
			selected_province.color = Color(1, 1, 1, 0.2) # Back to default
		#if selected_province != -1 and province_data.has(selected_province):
			#if clicked_province != selected_province:
				#selected_province.color = Color(1, 1, 1, 0.2) # Back to default
			#province_data[selected_province_id].color = Color(1, 1, 1, 0.2) # Back to default
			#print(province_data[selected_province_id])
		
		if clicked_province:
			var id = clicked_province.get_meta("province_id")
			# var name = clicked_province.get_meta("province_name")
			print("You clicked on Province ID %s" % [id])
			# print("You clicked on Province ID %s: %s" % [id, name])
			
			# Highlight the new province
			clicked_province.color = Color(1, 1, 0, 0.5) # Semi-transparent yellow
			print(clicked_province)
			selected_province = clicked_province
			#selected_province_id = id
		else:
			print("Clicked on the sea or an unassigned area.")
			selected_province = null

# This function loops through our polygons to find which one was clicked
func get_province_at_position(screen_position: Vector2) -> Polygon2D:
	for province in provinces_container.get_children():
		# We need to transform the screen position to the polygon's local coordinates
		var local_pos = province.to_local(screen_position)
		
		# check if position matches polygon
		if Geometry2D.is_point_in_polygon(local_pos, province.polygon):
			return province
			
	return null # Return null if no province was found at that position


"""
func _on_province_input_event(_viewport, event, _shape_idx):
	# find the parent Area2D
	var area_node = find_parent_area(event.get_position())
	if not area_node: 
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var province_id = area_node.get_meta("province_id")
		var data = province_data[province_id]
		print("Clicked on Province ID %s: %s" % [province_id, data.name])

		# --- HIGHLIGHTING LOGIC ---
		# Clear previous highlights
		for child in provinces_container.get_children():
			if child.has_node("Visual"):
				child.get_node("Visual").color = Color(1, 1, 1, 0) # Transparent
		
		# Highlight the currently clicked one
		var visual_node = area_node.get_node("Visual")
		visual_node.color = Color(1, 1, 0, 0.4) # Semi-transparent yellow

# Helper function to get the correct Area2D
func find_parent_area(global_pos):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_pos
	var results = space_state.intersect_point(query)
	for result in results:
		if result.collider is Area2D and result.collider.has_meta("province_id"):
			return result.collider
	return null
"""
