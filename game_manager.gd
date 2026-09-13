extends Node2D
var currentPlayer: Player
@onready var mainScene: Node2D = get_tree().current_scene
@onready var shipLevel = mainScene.get_node("ShipLevel")
@onready var deckLevel = mainScene.get_node("DeckLevel")

var currentScene = "Ship"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# the game timer probably goes in here too

func goDown():
	currentPlayer.scale = Vector2(0.5,0.5)
	shipLevel.process_mode = Node.PROCESS_MODE_DISABLED
	shipLevel.visible = false
	
	deckLevel.process_mode = Node.PROCESS_MODE_INHERIT
	deckLevel.visible = true
	
	currentPlayer.global_position = deckLevel.get_node("Marker2D").global_position
	currentScene = "Deck"
	pass
	
func goUp():
	currentPlayer.scale = Vector2(0.1,0.1)
	shipLevel.process_mode = Node.PROCESS_MODE_INHERIT
	shipLevel.visible = true
	
	deckLevel.process_mode = Node.PROCESS_MODE_DISABLED
	deckLevel.visible = false
	
	currentPlayer.global_position = shipLevel.get_node("Marker2D").global_position
	currentScene = "Ship"
	pass
