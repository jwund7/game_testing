extends StaticBody3D

const TEST = preload("res://world/scenes/test_environment.tscn")
const LEVEL = preload("res://world/scenes/level.tscn")

var current_setting: String = "test"

func _ready() -> void:
	# create the test environment and add it to the tree
	var new_map := TEST.instantiate()
	add_child(new_map)

func _process(_delta: float) -> void:
	# change_env bound to ; currently
	if Input.is_action_just_pressed("change_env"):
		# remove existing maps in the tree
		get_tree().call_group("Maps", "queue_free")
		# switch active map
		if current_setting == "level":
			var new_map := TEST.instantiate()
			add_child(new_map)
			current_setting = "test"
		else:
			var new_map := LEVEL.instantiate()
			add_child(new_map)
			current_setting = "level"
