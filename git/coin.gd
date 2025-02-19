extends Area3D

const ROTATE_SPEED = 2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(deg_to_rad(ROTATE_SPEED))
	
	


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		body.score += 34
		body.update_score()
		queue_free()
