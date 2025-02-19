extends Node3D

@export var coin_scene: PackedScene  # coin scene
@export var tree_scene: PackedScene  # tree scene
@export var bush_scene: PackedScene  # tree scene
@export var terrain_size: Vector2 = Vector2(90, 90)  # Terrain dimensions
@export var coin_count: int = 100  # Number of coins to spawn
@export var tree_count: int = 15   # Number of trees to spawn
@export var bush_count: int = 10

func _ready() -> void:
	spawn_coins()
	spawn_trees()
	spawn_bushes()

func spawn_coins():
	for i in range(coin_count):
		var coin_instance = coin_scene.instantiate()
		
		coin_instance.position = randomPointinTerrain()
		coin_instance.position.y = 1.0
		coin_instance.scale = Vector3(2.444, 2.444, 2.444)
		add_child(coin_instance)

func spawn_trees():
	for i in range(tree_count):
		var tree_instance = tree_scene.instantiate()
		
		tree_instance.position = randomPointinTerrain()
		tree_instance.position.y = 0.0
		add_child(tree_instance)
		
func spawn_bushes():
	for i in range(bush_count):
		var bush_instance = bush_scene.instantiate()
		
		bush_instance.position = randomPointinTerrain()
		bush_instance.position.y = 0.0
		bush_instance.scale = Vector3(2.444, 2.444, 2.444)
		add_child(bush_instance)
		
func randomPointinTerrain() -> Vector3:
	var rand_x = randf_range(-terrain_size.x / 2, terrain_size.x / 2)
	var rand_z = randf_range(-terrain_size.y / 2, terrain_size.y / 2)
	var rand_position = Vector3(rand_x, 0, rand_z)
	
	return rand_position
