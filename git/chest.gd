extends Area3D

const POINTS = 100
var chest_timer = 3.0  # Timer duration (in seconds)
var is_collecting = false  # Flag to prevent multiple collections during the timer
@onready var score_label = get_node("/root/Level1/CanvasLayer/ScoreLabel")
@onready var timer_label = get_node("/root/Level1/CanvasLayer/ChestTimer")


@onready var player = get_node("/root/Level1/Player") # Assuming the player node is here in the scene

var remaining_time = 0.0  # The remaining time for the chest to disappear
var chest_is_active = false  # Track if chest is active

func _ready() -> void:
	remaining_time = chest_timer
	timer_label.text = str(remaining_time)  # Initialize the display
	timer_label.visible = false  # Hide it initially

# Detect collision with the player
func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not is_collecting:  # Check if the player interacts
		is_collecting = true
		chest_is_active = true  # Activate the chest
		timer_label.visible = true  # Show the countdown timer on the screen
		update_timer_display()  # Update the UI immediately
		set_process(true)  # Start processing the countdown

# Update the displayed timer on the screen
func update_timer_display() -> void:
	timer_label.text = "Collecting in: " + str(int(remaining_time)) + "s"  # Update timer text

# Called every frame
func _process(delta: float) -> void:
	if chest_is_active:
		if remaining_time > 0:
			remaining_time -= delta  # Decrease the remaining time by the frame's delta time
			update_timer_display()  # Update the UI every frame
		else:
			_on_chest_timeout()  # Time expired, call chest timeout logic

# Function called when the timer expires
func _on_chest_timeout() -> void:
	if is_collecting:
		player.score += POINTS  # Add points to player score
		player.update_score()  # Update the score UI
		timer_label.visible = false  # Hide the countdown timer
		queue_free()  # Remove chest after collection
		is_collecting = false  # Reset the flag
		chest_is_active = false  # Deactivate chest
		set_process(false)  # Stop processing the countdown
