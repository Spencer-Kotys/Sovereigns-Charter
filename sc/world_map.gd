extends Node2D

@onready var visual_map_sprite: Sprite2D = $VisualMap
@onready var provinces_container = $Provinces
const GEOJSON_PATH = "res://resources/maps/Sea of Aerthos and Outlining Regions Cells 2025-08-21-19-15.geojson"

# dimensions of map PNG
const MAP_WIDTH = 1920.0
const MAP_HEIGHT = 957.0

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
		
		# province polygon 
		var province_polygon = Polygon2D.new()
		
		# convert JSON array points to vectors
		var polygon_points = PackedVector2Array()
		
		# project geographic points to a pixel coordinate
		for geo_point in data.geometry:
			var long = geo_point[0]
			var lat = geo_point[1]
			var pixel_coordinate = chart_projection(long, lat)
			polygon_points.append(pixel_coordinate)
		
		# enter province points into new polygon
		province_polygon.polygon = polygon_points
		
		# A semi-transparent white lets the main map show through.
		#province_polygon.color = Color(1, 1, 1, 0.2)
		province_polygon.color = Color(randf(), randf(), randf(), 0.8)
		
		# Store metadata directly on the node. This is very useful!
		province_polygon.set_meta("province_id", id)
		
		# add polygon
		provinces_container.add_child(province_polygon)

# Use _unhandled_input to not intercept GUI events
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		# get global mouse position in world coordinates
		var world_mouse_pos = get_global_mouse_position()
		# get which province is clicked
		var clicked_province = get_province_at_position(world_mouse_pos)
		
		# reset the previously selected province
		if selected_province != null:
			selected_province.color = Color(1, 1, 1, 0.2) # Back to default
		
		if clicked_province:
			var id = clicked_province.get_meta("province_id")
			print("You clicked on Province ID %s" % [id])
			
			# Highlight the new province
			clicked_province.color = Color(1, 1, 0, 0.5) # Semi-transparent yellow
			selected_province = clicked_province
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

# converts lat and long to pixel coordinates
func chart_projection(long, lat):
	var x = (long + 180.0) * (MAP_WIDTH / 360)
	
	# 90 - lat to flip Y-axis, Y pixels increase downwards 
	var y = (90.0 - lat) * (MAP_HEIGHT / 180)
	
	return Vector2(x,y)
