extends Node2D

# initialize provinces on startup
@onready var provinces_container = $Provinces
const GEOJSON_PATH = "res://resources/maps/Sea_of_Aerthos_and_Outlining_Regions_Cells_2025-08-21-19-15.geojson"

# var to store province data
var province_data = {}

func _ready():
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
			var province_id = feature.properties.i
			
			# store data
			province_data[province_id] = {
				"name": feature.properties.name,
				"state": feature.properties.state,
				"culture": feature.properties.culture,
				"population": feature.properties.population,
				"geometry": feature.geometry.coordinates[0]
			}

func draw_provinces():
	# for each province
	for id in province_data:
		var data = province_data[id]
		
		# make new province polygon
		var province_polygon = Polygon2D.new()
		
		# convert JSON array points to vectors
		var polygon_points = PackedVector2Array()
		for point in data.geometry:
			polygon_points.append(Vector2(point[0], point[1]))
		
		# enter province points into new polygon
		province_polygon.polygon = polygon_points
		
		# for debugging they are semi-transparent
		province_polygon.color = Color(1, 1, 1, 0.1)
		
		# ID names for the scene tree
		province_polygon.name = "Province_" + str(id)
		
		# add new province to container
		provinces_container.add_child(province_polygon)
