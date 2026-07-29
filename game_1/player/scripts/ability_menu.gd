extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var screen_center: Vector2 = Vector2.ZERO
var inner_radius: float = 64.0
var outer_radius: float = 384.0
var line_width: float = 3.0

var base_color: Color = Color("4480d0")
var highlight_color: Color = Color("4190cc")
var line_color: Color = Color("8bcfeb")

var abilities: Array[String] = ["crouch", "dodge", "levitate", "grapple"]
var selected_ability: int

func _draw() -> void:
	# draw a circle for selection wheel
	draw_circle(screen_center, outer_radius, base_color)
	
	# draw abilities on circle
	for i in range(len(abilities)):
		# TAU = 2pi
		var start_rad: float = TAU * i / len(abilities)
		var end_rad: float = TAU * (i + 1) / len(abilities)
		# divide by negative due to Godot's 2D coordinate system
		var avg_rad: float = (start_rad + end_rad) / -2
		# get a normalized vector for the angle in between the two new lines
		var point: Vector2 = Vector2.from_angle(avg_rad).normalized()
		var avg_radius: float = (inner_radius + outer_radius) / 2
		
		# draw selection highlight
		# this makes a lot more sense if explained visually but basically a point is created at
		# the specified number of subdivisions for the hovered ability at both the inner and
		# outer circles, then the outer points have their order reversed so the polygon makes
		# the correct shape instead of clipping through itself
		if selected_ability == i:
			var points_in_arc: int = 12
			var points_inner := PackedVector2Array()
			var points_outer := PackedVector2Array()
			for j in range(points_in_arc + 1):
				var angle: float = start_rad + (j * (end_rad - start_rad)) / points_in_arc
				points_inner.append(inner_radius * Vector2.from_angle(TAU - angle))
				points_outer.append(outer_radius * Vector2.from_angle(TAU - angle))
			points_outer.reverse()
			draw_polygon(points_inner + points_outer, PackedColorArray([highlight_color]))
		
		# get the screen size of the string to center the drawn text
		var font_offset: Vector2 = ThemeDB.fallback_font.get_string_size(abilities[i]) / 2
		var font_off_y: float = ThemeDB.fallback_font.get_ascent()
		var font_location: Vector2 = (point * avg_radius) + Vector2(0, font_off_y) - font_offset
		# draw ability name
		draw_string(ThemeDB.fallback_font, font_location, abilities[i])
		
		# draw an inner circle
		draw_arc(screen_center, inner_radius, 0, TAU, 32, line_color, line_width, true)
		# draw an outer circle
		draw_arc(screen_center, outer_radius, 0, TAU, 64, line_color, line_width, true)
	
	# draw lines on circle
	# since draw calls cover each other, lines are drawn after to cover selection highlight edges
	for i in range(len(abilities)):
		var rad: float = TAU * i / len(abilities)
		var point: Vector2 = Vector2.from_angle(rad).normalized()
		draw_line(point * inner_radius, point * outer_radius, line_color, line_width, true)

func _process(_delta: float) -> void:
	# get hovered ability by mouse position
	var mouse_pos: Vector2 = get_local_mouse_position()
	var mouse_length: float = mouse_pos.length()
	if mouse_length > inner_radius:
		# multiply by -1 due to Godot's 2D coordinate system
		var mouse_angle: float = fposmod(-1 * mouse_pos.angle(), TAU)
		selected_ability = ceil((mouse_angle / TAU) * len(abilities) - 1)
	# if no ability is hovered, set selected_ability to value outside of range
	else:
		selected_ability = -1
	
	# redraw circle every frame
	queue_redraw()

func open() -> void:
	animation_player.play("open")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close() -> String:
	animation_player.play("close")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# return the selected ability if there is one
	if selected_ability == -1:
		return ""
	else:
		return abilities[selected_ability]
