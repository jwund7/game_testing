extends Node

const BALL = preload("res://weapon/resources/ball.tres")
const EXPLOSION = preload("res://weapon/resources/explosion.tres")
const CURSE = preload("res://weapon/resources/curse.tres")

# general nodes required for spell select function
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var spell_indicator: RichTextLabel = $ProgressBar/SpellIndicator
@onready var spell_menu: Control = $SpellMenu
# nodes required for spell usage
@onready var wand: Node3D = $"../Head/PlayerCam/Wand"

# menu variables
var select_open: bool = false
var selected_spell: String
# spell cooldown variables
var ball_cooldown: float = 0.0
var explosion_cooldown: float = 0.0
var curse_cooldown: float = 0.0

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
	
	# handle spell usage
	if Input.is_action_just_pressed("left_click") and not select_open:
		if selected_spell == "ball" and ball_cooldown <= 0:
			wand.use_spell("ball")
			ball_cooldown = BALL.cooldown
		if selected_spell == "explosion" and explosion_cooldown <= 0:
			wand.use_spell("explosion")
			explosion_cooldown = EXPLOSION.cooldown
		if selected_spell == "curse" and curse_cooldown <= 0:
			wand.use_spell("curse")
			curse_cooldown = CURSE.cooldown

func _physics_process(delta: float) -> void:
	# run cooldowns for all spells
	if ball_cooldown > 0:
		ball_cooldown -= delta
	if explosion_cooldown > 0:
		explosion_cooldown -= delta
	if curse_cooldown > 0:
		curse_cooldown -= delta
	
	if selected_spell == "ball":
		progress_bar.value = (ball_cooldown / BALL.cooldown) * 100
	if selected_spell == "explosion":
		progress_bar.value = (explosion_cooldown / EXPLOSION.cooldown) * 100
	if selected_spell == "curse":
		progress_bar.value = (curse_cooldown / CURSE.cooldown) * 100
