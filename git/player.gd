extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVTY = 0.002
const COMBO_TIME_LIMIT = 3.0  # Time limit for combo bonus
const BASE_POINTS = 10  # Base points for simple actions
const BONUS_POINTS = 20  # Bonus points for specific actions

@onready var camera_controller = $CameraController
@onready var camera = $CameraController/CameraTarget/Camera3D
@onready var anim_player = $CollisionShape3D/Mage/AnimationPlayer 
@onready var score_label = $"../CanvasLayer/ScoreLabel"
@onready var timer_label = $"../CanvasLayer/TimerLabel"
@onready var timer = $Timer
@onready var game_over_screen = $"../CanvasLayer/GameOverScreen"
@onready var game_over_label = $"../CanvasLayer/GameOverScreen/GameOverLabel"
@onready var try_again_button = $"../CanvasLayer/GameOverScreen/TryAgainButton"
@onready var high_score_label = $"../CanvasLayer/GameOverScreen/HighScoreLabel"  # New label for high score
@onready var main_menu = $"../CanvasLayer/MainMenu"  # Main Menu Control with Start, Leaderboard, and Quit buttons

var yaw = 0
var pitch = 0
var score = 0
var time_left = 120
var last_action_time = 0.0  # To track time for combos
var combo_multiplier = 1  # Combo multiplier for consecutive actions
var current_combo_time = 0.0  # Time elapsed for current combo
var high_score = 0  # Variable to hold the high score
var game_over_flag = false  # Flag to track if the game is over

func _ready() -> void:
	# Update score/timer labels and load saved high score.
	update_score()
	update_timer()
	load_high_score()  # Load the high score when the game starts
	
	# If the main menu is visible, keep the mouse visible. Otherwise, capture it and start the timer.
	if main_menu and main_menu.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		timer.start()

func _input(event: InputEvent) -> void:
	# Disable input if the game is over or if the main menu is active.
	if game_over_flag or (main_menu and main_menu.visible):
		return

	if event is InputEventMouseMotion:
		yaw -= event.relative.x * MOUSE_SENSITIVTY
		pitch -= event.relative.y * MOUSE_SENSITIVTY
		pitch = clamp(pitch, -0.4, 0.4)
		
		camera_controller.rotation_degrees.y = rad_to_deg(yaw)
		camera.rotation_degrees.x = rad_to_deg(pitch)

func _physics_process(delta: float) -> void:
	# Disable movement if the game is over or if the main menu is active.
	if game_over_flag or (main_menu and main_menu.visible):
		return

	# Add gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim_player.play("Jump_Full_Short")
		increase_score(BASE_POINTS)  # Add points on each jump

	# Get input direction and handle movement.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var forward = camera_controller.transform.basis.z
	var right = camera_controller.transform.basis.x
	
	var direction = (right * input_dir.x + forward * input_dir.y).normalized()
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		rotation.y = camera_controller.rotation.y
		anim_player.play("Walking_A")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		anim_player.play("Idle")

	move_and_slide()

	# Make Camera Controller match the position of the player.
	camera_controller.position = lerp(camera_controller.position, position, 0.15)

	# Update combo timer.
	if current_combo_time < COMBO_TIME_LIMIT:
		current_combo_time += delta
	else:
		reset_combo()

func update_score():
	score_label.text = "Score: " + str(score)

func update_timer():
	timer_label.text = "Time Left: " + str(time_left)

func _on_timer_timeout():
	time_left -= 1
	update_timer()
	if time_left <= 0:
		game_over()

func game_over():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	game_over_screen.visible = true  # Show the Game Over UI
	game_over_flag = true  # Set the game over flag to true
	game_over_label.text = "Your Score: " + str(score)

	# Check and update high score.
	if score > high_score:
		high_score = score
		save_high_score()  # Save the new high score

	high_score_label.text = "High Score: " + str(high_score)  # Display the high score

func _on_try_again_button_pressed():
	get_tree().reload_current_scene()

# Function to increase score and apply combo multiplier.
func increase_score(points: int) -> void:
	if current_combo_time < COMBO_TIME_LIMIT:
		combo_multiplier += 1  # Increase combo multiplier for consecutive actions
	else:
		combo_multiplier = 1  # Reset multiplier if time exceeds the combo time limit

	var final_points = points * combo_multiplier
	score += final_points
	update_score()

	# Display combo multiplier on screen.
	if combo_multiplier > 1:
		score_label.text += " x" + str(combo_multiplier)

# Function to reset the combo system.
func reset_combo() -> void:
	combo_multiplier = 1
	current_combo_time = 0.0

# Function to load the high score from a file.
func load_high_score() -> void:
	var file = FileAccess.open("user://highscore.dat", FileAccess.READ)
	if file:
		high_score = file.get_var()  # Read the high score from the file
		file.close()

# Function to save the high score to a file.
func save_high_score() -> void:
	var file = FileAccess.open("user://highscore.dat", FileAccess.WRITE)
	file.store_var(high_score)  # Save the high score to the file
	file.close()


# --- Main Menu Button Signal Functions ---
# (Connect these functions to the pressed() signals of your Main Menu buttons.)

func _on_StartGameButton_pressed():
	# Hide the Main Menu and start the game.
	if main_menu:
		main_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	timer.start()

func _on_QuitGameButton_pressed():
	get_tree().quit()
