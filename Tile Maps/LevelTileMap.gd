class_name LevelTileMap extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelManager.change_tilemap_bounds(get_tilemap_bounds())
	pass # Replace with function body.


func get_tilemap_bounds() -> Array[Vector2]:
	var bounds: Array[Vector2] = []
	var used_rect: Rect2i = get_used_rect()
	var tile_size_px: Vector2 = Vector2(tile_set.tile_size)

	bounds.append(
		Vector2(used_rect.position) * tile_size_px
	)
	bounds.append(
		Vector2(used_rect.end) * tile_size_px
	)
	return bounds
