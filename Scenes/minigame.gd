extends Control
@onready var parentCanvas: CanvasLayer = get_parent()
@onready var mainFrame = $MainFrame
@onready var hintText = $HintText

var currentPlayer:Player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.currentPlayer:
		currentPlayer = GameManager.currentPlayer
	else:
		GameManager.playerReady.connect(func(newPlayer):currentPlayer = newPlayer)
		
	InteractionManager.minigameScript = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func cannonMinigame():
	var minigameFrame = mainFrame.get_node("CannonMinigame")
	print('cannon minigame called')
	pass

var gameFunctions = {
	"CannonMinigame": cannonMinigame,
}


func startGame(gameType:String):
	if currentPlayer.doingMinigame == true: return
	
	currentPlayer.movementSpeed = 0
	currentPlayer.doingMinigame = true
	
	parentCanvas.visible = true
	var gameFunction = gameFunctions[gameType]
	
	#toggle visibility of minigame
	for child in mainFrame.get_children():
		if child.name == gameType:
			child.visible = true
		else:
			child.visible = false
	
	gameFunction.call()
	# probably yield or wait here, to reset movement speed after minigame
	#currentPlayer.movementSpeed = currentPlayer.baseSpeed
