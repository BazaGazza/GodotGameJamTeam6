extends Control
@onready var parentCanvas = get_parent()
@onready var mainFrame = $MainFrame
@onready var hintText = $HintText
@onready var backgroundFrame = $Background

	
var currentPlayer:Player = null

var defaultPositions = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.currentPlayer:
		currentPlayer = GameManager.currentPlayer
	else:
		GameManager.playerReady.connect(func(newPlayer):currentPlayer = newPlayer)
	InteractionManager.minigameScript = self
	savePositions(mainFrame)

	

	
func savePositions(parent):
	for child in parent.get_children():
		if child is CharacterBody2D:
			defaultPositions[child] = child.position
		savePositions(child)

func resetPositions():
	for child in defaultPositions:
		var pos = defaultPositions[child]
		child.position = pos

func fadeLabel(label,transparency,duration = 0.65):
	var tween = create_tween()
	tween.tween_property(label,"modulate:a",transparency,duration)
	pass
	
func richTextWavy(text:String):
	return "[shake rate=8.0 level=2 connected=0]"+text+"[/shake]"

@onready var cannonballBody = $MainFrame/CannonMinigame.get_node("Cannonball")

var dragNode = null
var dragGoal = null
var dragSpeed = 3000

var ramVelocity = Vector2.ZERO
var previousPosition = null
var currentRamSpeed = 0

var currentPlank:CharacterBody2D = null
var hoveringPlank:bool = false
var placedPlanks = 0

signal placePlankSignal

func moveDrag(delta):
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dragNode.velocity = Vector2.ZERO
		dragNode = null
		if currentPlank and hoveringPlank:
			placePlankSignal.emit()
			
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
		if GameManager.currentMinigame != "CannonMinigame": return
		if dragNode != null and dragNode.name == "Rod":
			var currentPos = dragNode.global_position
			if previousPosition == null: 
				previousPosition = currentPos
			
			# i'm not using distance_to because only the horizontal movement is relevant
			distance = abs(currentPos.x - previousPosition.x)
			currentRamSpeed += distance/10
			previousPosition = currentPos
	
	#1/distance, so standing still is more penalized, and making big movements, there's less decay
	if GameManager.currentMinigame != "CannonMinigame": return
	var decay = 15*(1/distance)
	currentRamSpeed = clamp(currentRamSpeed-(delta*decay),0,currentRamSpeed)
	
	cannonballBody.velocity = ramVelocity
	ramVelocity = ramVelocity.move_toward(Vector2.ZERO, 1000 * delta)
	cannonballBody.move_and_slide()
	
	

var gameCanceled = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up") or event.is_action_pressed("move_down") or event.is_action_pressed("move_left"):
		gameCanceled = true
		
	
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
	
	while not variables.dragFinished and not gameCanceled:
		await get_tree().process_frame
	
	variables.dragFinished = false
	dragNode = null
	powderBody.input_event.disconnect(dragFunction)
	PowderArea.body_entered.disconnect(areaFunction)
	if gameCanceled: return
	
	hintText.modulate.a = 0
	fadeLabel(hintText,1)
	hintText.text = richTextWavy("load the cannonball...")
	
	dragSpeed = 1200
	BallArea1.body_entered.connect(areaFunction)
	cannonballBody.input_event.connect(dragFunction.bind(cannonballBody))
	
	while not variables.dragFinished and not gameCanceled:
		await get_tree().process_frame
	variables.dragFinished = false
	dragNode = null
	cannonballBody.input_event.disconnect(dragFunction)
	BallArea1.body_entered.disconnect(areaFunction)
	if gameCanceled: return
		
	hintText.modulate.a = 0
	fadeLabel(hintText,1)
	hintText.text = richTextWavy("ram the cannonball!")
	
	dragSpeed = 3000
	rodBody.input_event.connect(dragFunction.bind(rodBody))
	
	var ramFunction = func(body):
		if body.name == "Cannonball":
			ramVelocity = Vector2(-currentRamSpeed*12,0)
			currentRamSpeed = 0
	var finishRamFunction = func(body):
		if body.name == "Cannonball":
			variables.dragFinished = true

	rodBody.get_node("Area2D").body_entered.connect(ramFunction)
	minigameFrame.get_node("Cannon/BallArea2").body_entered.connect(finishRamFunction)
	
	while not variables.dragFinished and not gameCanceled:
		await get_tree().process_frame
	rodBody.get_node("Area2D").body_entered.disconnect(ramFunction)
	if gameCanceled: return
	
	fadeLabel(hintText,0,0.5)
	print("Finished Cannon Minigame")
	
	await get_tree().create_timer(1.0).timeout
	return

func plankMinigame():
	var minigameFrame = mainFrame.get_node("PlankMinigame")
	var plankTemplate:CharacterBody2D = minigameFrame.get_node("PlankTemplate")
	var holeArea:Area2D = minigameFrame.get_node("HoleArea")
	var planksHolder:Node2D = holeArea.get_node("Planks")
	
	plankTemplate.visible = false
	
	for child in planksHolder.get_children():
		child.visible = false
	for child in minigameFrame.get_children():
		if child.name.find("PlankClone") != -1:
			child.queue_free()
	
	var plankCloneList = []
	dragNode = null
	hoveringPlank = false
	currentPlank = null
	placedPlanks = 0
	var vars = {
		"nailing":false
	}
	
	for i in range(1,5,1):
		var plankClone = plankTemplate.duplicate()
		plankClone.name = "PlankClone"+str(i)
		plankClone.rotation_degrees = randf_range(-40,40)
		plankClone.position = plankClone.position + Vector2(randf_range(-25,25),randf_range(-25,25))
		plankClone.visible = true
		minigameFrame.add_child(plankClone)
		plankCloneList.append(plankClone)

	hintText.modulate.a = 0
	fadeLabel(hintText,1)
	hintText.text = richTextWavy("place a plank...")

	var dragFunction = func(viewport,event,shape_idx,newBody):
		if vars.nailing: return
		if currentPlank != null and newBody != currentPlank: return # only 1 plank at a time
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				currentPlank = newBody
				dragNode = newBody
				newBody.z_index = placedPlanks
				
	var enterFunction = func(body):
		if body.name.find("PlankClone") != -1:
			hoveringPlank = true
	var exitFunction = func(body):
		if body.name.find("PlankClone") != -1:
			hoveringPlank = false
			
	dragSpeed = 3000
	for clone in plankCloneList:
		clone.input_event.connect(dragFunction.bind(clone))
		
	holeArea.body_entered.connect(enterFunction)
	holeArea.body_exited.connect(exitFunction)

	var placeFunction = func():
		vars.nailing = true
		
		hintText.modulate.a = 0
		fadeLabel(hintText,1)
		hintText.text = richTextWavy("nail down the plank...")
		
		currentPlank.queue_free()
		currentPlank = null
		
		var newPlank = planksHolder.get_node("Plank"+str(placedPlanks+1))
		newPlank.visible = true
		var originalScale = newPlank.scale
		newPlank.scale = originalScale * 1.15

		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(newPlank, "scale", originalScale, 0.2)

		var variables = {
			"nailCount":0
		}
		for nail:Sprite2D in newPlank.get_children():
			var area:Area2D = nail.get_node("Area2D")
			nail.self_modulate = Color(0,3,0)
			
			var nailTween = create_tween()
			nailTween.set_loops()
			nailTween.tween_property(nail, "self_modulate:a", 0.2, 0.5)
			nailTween.tween_property(nail, "self_modulate:a", 1.0, 0.5)
			
			var connection = []

			var nailFunction = func(viewport, event, shape_idx):
				if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
					nailTween.kill()
					variables.nailCount += 1
					nail.self_modulate = Color(1,1,1)
					area.input_event.disconnect(connection[0])

			connection.append(nailFunction)
			area.input_event.connect(nailFunction)
			
		while variables.nailCount < 4:
			await get_tree().process_frame
			
		hintText.modulate.a = 0
		fadeLabel(hintText,1)
		hintText.text = richTextWavy("place a plank...")
		vars.nailing = false
		placedPlanks += 1

	
	placePlankSignal.connect(placeFunction)
	
	while placedPlanks < 4 and not gameCanceled:
		await get_tree().process_frame
		
	placePlankSignal.disconnect(placeFunction)
		
func wheelMinigame(): #RODOLFO ADD WHEEL
	currentPlayer.playerCamera.offset = Vector2(300,currentPlayer.playerCamera.offset.y)
	
	
	
	currentPlayer.playerCamera.offset = Vector2(0,currentPlayer.playerCamera.offset.y)
	
	var wheel_node = mainFrame.get_node("WheelMinigame/Wheel")
	
	
	var rotation_speed: float = 8.0
	#IDEA Player drags tips of steering wheel to steer in different directions to complete ship by steering away from incoming rocks 
	#The ship will then move up or down in y-direction to steer clear of rocks
	var delta = get_process_delta_time()
	
	var target_angle = (wheel_node.get_global_mouse_position() - wheel_node.global_position).angle()
	wheel_node.rotation = lerp_angle(wheel_node.rotation, target_angle, rotation_speed * delta)

	#Ship moving after rotation made 

	
#Place to add and connect interactables via names
var gameFunctions = {
	"CannonMinigame": cannonMinigame,
	"PlankMinigame": plankMinigame,
	"WheelMinigame": wheelMinigame,
}


func startGame(gameType:String,interactableObject:Interactable):
	if currentPlayer.doingMinigame == true: return
	resetPositions()
	currentPlayer.movementSpeed = 0
	currentPlayer.doingMinigame = true
	
	parentCanvas.visible = true
	var gameFunction = gameFunctions[gameType]
	GameManager.currentMinigame = gameType
	
	#toggle visibility of minigame
	for child in mainFrame.get_children():
		if child.name == gameType:
			child.process_mode = Node.PROCESS_MODE_INHERIT
			child.visible = true
		else:
			child.process_mode = Node.PROCESS_MODE_DISABLED
			child.visible = false
	
	if gameType == "WheelMinigame":
		backgroundFrame.visible = false
	else:
		backgroundFrame.visible = true	

	gameCanceled = false
	await gameFunction.call()
			
	if not gameCanceled:
		if gameType == "CannonMinigame":
			#also do the aiming mini game
			var aimer = interactableObject.get_node("Aimer")
			mainFrame.visible = false
			$Background.visible = false
			hintText.modulate.a = 0
			fadeLabel(hintText,1)
			hintText.text = richTextWavy("press 'E' to fire the cannon!")
			
			await aimer.startAim()
			mainFrame.visible = true
			$Background.visible = true
		elif gameType == "PlankMinigame":
			interactableObject.queue_free()
	
		
	GameManager.currentMinigame = ""
	currentPlayer.movementSpeed = currentPlayer.baseSpeed
	currentPlayer.doingMinigame = false
	parentCanvas.visible = false
