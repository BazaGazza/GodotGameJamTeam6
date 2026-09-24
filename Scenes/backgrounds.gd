extends Node2D

@export var ocean_speed: float = 50.0

@onready var bg1: Sprite2D = $OceanBackground
@onready var bg2: Sprite2D = $OceanBackground2

# Variable to hold the dynamically calculated width
var sprite_width: float = 0.0

func _ready() -> void:
	# Ensure the node and texture exist before attempting to read dimensions
	if bg1 and bg1.texture:
		sprite_width = bg1.texture.get_width() * bg1.scale.x
		
		# Optional: Automatically position bg2 directly next to bg1 on start
		bg2.position.x = bg1.position.x + sprite_width

func _process(delta: float) -> void:
	bg1.position.x -= ocean_speed * delta
	bg2.position.x -= ocean_speed * delta

	# Seamless loop logic using the dynamic sprite_width
	if bg1.position.x <= -sprite_width:
		bg1.position.x = bg2.position.x + sprite_width

	if bg2.position.x <= -sprite_width:
		bg2.position.x = bg1.position.x + sprite_width
