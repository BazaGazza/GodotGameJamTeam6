extends Node2D

@export var ocean_speed: float = 50.0
var isStuck = false
@onready var bg1: Sprite2D = $OceanBackground
@onready var bg2: Sprite2D = $OceanBackground2
@onready var rock: CharacterBody2D = $rocky
@onready var ship: Area2D = $"../ShipNode/ShipMask/ShipLevel/HoleArea"

var steeringInteractable:Interactable

# Variable to hold the dynamically calculated width
var sprite_width: float = 0.0
var originx = 0 
var originy = 0 
func _ready() -> void:
	# Ensure the node and texture exist before attempting to read dimensions
	steeringInteractable = get_tree().current_scene.get_node("ShipNode/ShipMask/ShipLevel/Interactables/Steering Wheel")
	steeringInteractable.set_meta("Cooldown",true)
	
	if bg1 and bg1.texture:
		sprite_width = bg1.texture.get_width() * bg1.scale.x
		
		# Optional: Automatically position bg2 directly next to bg1 on start
		bg2.position.x = bg1.position.x + sprite_width
		originx = rock.position.x 
		originy = rock.position.y 
	get_tree().current_scene.modulate = Color(1.0, 1.0, 1.0, 1.0)
	

func _process(delta: float) -> void:
	
	##Rock characterBody is spawned randomly in range of time on the path of the ship and moves with background velocity 
	##Add collision detection to freeze movement of all sprites if rock collides
	## Also find drain rate and increase or find it and ask for isStuck collision checker 
	##Minigame script will move the rock sprite and then the sprites should move automatically, once the rock reaches the end a random variable will respawn it in the trajectory again 
	
	if(!(isStuck)): #Freeze sprite movement until wheel minigame is cleared
		bg1.position.x -= ocean_speed * delta
		bg2.position.x -= ocean_speed * delta
		rock.position.x -= ocean_speed * delta
		#print(rock.position.x)
		
	
	
	# Seamless loop logic using the dynamic sprite_width
	if bg1.position.x <= -sprite_width:
		bg1.position.x = bg2.position.x + sprite_width

	if bg2.position.x <= -sprite_width:
		bg2.position.x = bg1.position.x + sprite_width

	if rock.position.x <= 0:
		rock.position.x = randf_range(700, 1300)
		rock.position.y = originy


func _on_hole_area_body_entered(body: Node2D) -> void:
	if body.name == "rocky":
		steeringInteractable.set_meta("Cooldown",false)
		AudioManager.playSfx("HitRock")
		isStuck = true


func _on_hole_area_body_exited(body: Node2D) -> void:
	if body.name == "rocky":
		("free of rock")
		isStuck = false
