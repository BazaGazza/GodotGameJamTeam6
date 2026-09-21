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


var dragNode = null
var dragGoal = null
var dragOffset = null

func moveDrag(delta):
	if dragOffset == null: return
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dragNode.velocity = Vector2.ZERO
		dragNode = null
		return

	dragGoal = dragNode.get_global_mouse_position() + dragOffset
	dragNode.velocity = ((dragGoal - dragNode.global_position).normalized() * 1200)
	dragNode.move_and_slide()

func _process(delta: float) -> void:
	if dragNode != null:
		moveDrag(delta)
		


func cannonMinigame():
	var minigameFrame = mainFrame.get_node("CannonMinigame")
	hintText.text = "load the powder charge..."
	
	var powderBody = minigameFrame.get_node("Powder")
	var rodUI = minigameFrame.get_node("Rod")
	var cannonballUI = minigameFrame.get_node("Cannonball")
	
	# i have to use a dictionary to store the variables,
	#because for lambda functions like 'dragConnection' when it's created (everytime guiinput is called), it will make it's own set of variables,
	# so 'dragging' will get set to false everytime.
	# a dictioanry works because it doesn't clone the dictionary, only gets a reference when the lambda functoin is called
	var variables = {
		"powderFinished":false
	}

	var dragConnection = powderBody.input_event.connect(func(viewport,event,shape_idx):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				dragNode = powderBody
				dragOffset = powderBody.global_position - powderBody.get_global_mouse_position()
	)
	
	while not variables.powderFinished:
		await get_tree().process_frame
	
	return

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
	
	await gameFunction.call()
	currentPlayer.movementSpeed = currentPlayer.baseSpeed
	currentPlayer.doingMinigame = false
