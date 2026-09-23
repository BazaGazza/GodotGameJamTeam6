extends Control
@onready var parentCanvas = get_parent()
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

func fadeLabel(label,transparency):
	var tween = create_tween()
	tween.tween_property(label,"modulate:a",transparency, 2)
	pass
	
func richTextWavy(text:String):
	return "[shake rate=8.0 level=2 connected=0]"+text+"[/shake]"

@onready var cannonballBody = $MainFrame/CannonMinigame.get_node("Cannonball")

var ramVelocity = Vector2.ZERO
var dragNode = null
var dragGoal = null
var dragSpeed = 3000

var previousPosition = null
var currentRamSpeed = 0

func moveDrag(delta):
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dragNode.velocity = Vector2.ZERO
		dragNode = null
		return

	dragGoal = get_global_mouse_position()

	var offset = dragGoal - dragNode.global_position
	var distance = offset.length()

	if distance < 15:
		# check so it doesn't jitter in place
		dragNode.velocity = Vector2.ZERO
		return

	var direction = offset.normalized()

	var speed = min(dragSpeed, distance * dragSpeed/300)
	dragNode.velocity = direction * speed
	#i'm using move and slide from characterbody2d specifically to detect collision
	dragNode.move_and_slide()

func _physics_process(delta: float) -> void:
	
	var distance = 1
	
	if dragNode != null:
		moveDrag(delta)
		if dragNode != null and dragNode.name == "Rod":
			var currentPos = dragNode.global_position
			if previousPosition == null: 
				previousPosition = currentPos
			
			# i'm not using distance_to because only the horizontal movement is relevant
			distance = abs(currentPos.x - previousPosition.x)
			currentRamSpeed += distance/10
			previousPosition = currentPos
	
	#1/distance, so standing still is more penalized, and making big movements, there's less decay
	var decay = 15*(1/distance)
	currentRamSpeed = clamp(currentRamSpeed-(delta*decay),0,currentRamSpeed)
	
	cannonballBody.velocity = ramVelocity
	ramVelocity = ramVelocity.move_toward(Vector2.ZERO, 500 * delta)
	cannonballBody.move_and_slide()
	


func cannonMinigame():
	var minigameFrame = mainFrame.get_node("CannonMinigame")
	hintText.modulate.a = 0
	fadeLabel(hintText,1)
	hintText.text = richTextWavy("place the powder charge...")
	
	var powderBody = minigameFrame.get_node("Powder")
	var rodBody = minigameFrame.get_node("Rod")
	
	var PowderArea = minigameFrame.get_node("Cannon/PowderArea")
	var BallArea1 = minigameFrame.get_node("Cannon/BallArea1")

	# the variable has to be stored in a dictionary, cause everytime the .connect(function) is created, it creates its own set of variables
	# so setting drag finished wasn't working properly inside of the function
	# a dictionary works, because it passes the reference 
	var variables = {
		"dragFinished":false
	}
	

	var dragFunction = func(viewport,event,shape_idx,newBody):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				dragNode = newBody
	var areaFunction = func(body):
		if body.name == "Powder" or body.name == "Cannonball" or body.name == "Rod":
			variables.dragFinished = true
			
			
	dragSpeed = 3000
	PowderArea.body_entered.connect(areaFunction)
	powderBody.input_event.connect(dragFunction.bind(powderBody))
	
	while not variables.dragFinished:
		await get_tree().process_frame
	
	variables.dragFinished = false
	dragNode = null
	powderBody.input_event.disconnect(dragFunction)
	PowderArea.body_entered.disconnect(areaFunction)
	
	hintText.modulate.a = 0
	fadeLabel(hintText,1)
	hintText.text = richTextWavy("load the cannonball...")
	
	dragSpeed = 1200
	BallArea1.body_entered.connect(areaFunction)
	cannonballBody.input_event.connect(dragFunction.bind(cannonballBody))
	
	while not variables.dragFinished:
		await get_tree().process_frame
	variables.dragFinished = false
	dragNode = null
	cannonballBody.input_event.disconnect(dragFunction)
	BallArea1.body_entered.disconnect(areaFunction)
	
	hintText.modulate.a = 0
	fadeLabel(hintText,1)
	hintText.text = richTextWavy("ram the cannonball!")
	
	dragSpeed = 3000
	rodBody.input_event.connect(dragFunction.bind(rodBody))
	
	var ramFunction = func(body):
		if body.name == "Cannonball":
			ramVelocity = Vector2(-currentRamSpeed*8,0)
			currentRamSpeed = 0
	var finishRamFunction = func(body):
		if body.name == "Cannonball":
			variables.dragFinished = true

		

			
	rodBody.get_node("Area2D").body_entered.connect(ramFunction)
	minigameFrame.get_node("Cannon/BallArea2").body_entered.connect(finishRamFunction)
	
	while not variables.dragFinished:
		await get_tree().process_frame
		
	rodBody.get_node("Area2D").body_entered.disconnect(ramFunction)
	
	print("Finished Cannon Minigame")
	
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
	parentCanvas.visible = false
