extends Node

# general nodes required for spell select function
@onready var spell_indicator: RichTextLabel = $SpellIndicator
@onready var spell_menu: Control = $SpellMenu

# menu variables
var select_open: bool = false
var selected_spell: String

var player: Player = PlayerManager.player

func _ready() -> void:
	# start game using ball spell
	selected_spell = "ball"
	spell_indicator.text = selected_spell
	# wait until player exists and get the player
	await get_parent().ready
	player = PlayerManager.player

func _unhandled_input(_event: InputEvent) -> void:
	# handle selection wheel opening and closing
	var ability_select: bool = player.ability_controller.select_open
	# only allow wheel opening if no abilities are active
	if Input.is_action_just_pressed("spell_select") and not ability_select:
		select_open = true
		spell_menu.open()
	if Input.is_action_just_released("spell_select"):
		# get the currently used ability
		var current_ability: String = selected_spell
		select_open = false
		selected_spell = spell_menu.close()
		# if no ability was selected with the wheel, revert to previously used ability
		if selected_spell == "":
			selected_spell = current_ability
		# change spell indicator to current spell
		spell_indicator.text = selected_spell
