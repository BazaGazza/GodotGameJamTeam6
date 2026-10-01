extends Node2D
var currentPlayer: Player

var currentHealth = 100
const maxHealth = 100
var timer = 0

var currentScene:Node = null
var currentSceneName = "Ship"
var currentMinigame:String = ""

var spawnedHoles:int = 0
var InteractablesNode:Node2D = null
var holeArea:Area2D = null
var holeShape = null
var holeScene:PackedScene = preload("res://Scenes/interactable-Hole.tscn")
var targetScene:PackedScene = preload("res://Scenes/target_area.tscn")
var timerUI:Control = null

const shakeMaxLength = 20
var maxShakeRate:float = 150.0
var maxShakeLevel:float = 35.0
var currentShakeRate:float = 0.0
var currentShakeLevel:float = 0.0
var baseShakeLevel = 0.0
var baseShakeRate = 0.0

var fadeScene = preload("res://Scenes/fade_screen.tscn")
var fadeScreen:CanvasLayer
var gameActive = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fadeScreen = fadeScene.instantiate()
	add_child(fadeScreen)
	resetGame()
	fadeFromBlack()

func fadeToBlack(duration = 0.25):
	fadeScreen.fadeToBlack()
func fadeFromBlack(duration = 0.25):
	fadeScreen.fadeFromBlack()

func _process(delta: float) -> void:
	if currentHealth <= 0 and gameActive:
		endGame()
		return
	
	currentScene = get_tree().current_scene
	if currentScene == null: return
	if currentScene.name != "Main": return
	if InteractablesNode == null:
		InteractablesNode = currentScene.get_node("ShipNode").get_node("ShipMask").get_node("ShipLevel").get_node("Interactables")
	if timerUI == null:
		timerUI = currentScene.get_node("TimerUI").get_node("timerUI")

	timer += delta
	timerUI.get_node("TextLabel").text = richTextWavy(str(timer).pad_decimals(2))
	
	var progress = clamp(timer/shakeMaxLength,0,1)

	currentShakeLevel = round(lerp(baseShakeLevel,maxShakeLevel,progress))
	currentShakeRate = round(lerp(baseShakeRate,maxShakeRate,progress))

	# the game timer probably goes in here too
	var timerInt = floor(timer)
	if timerInt > 0 and spawnedHoles < timerInt and spawnedHoles < 3:
		spawnedHoles += 1
		spawnHole()

	


signal playerReady(player)
func setCurrentPlayer(player):
	currentPlayer = player
	playerReady.emit(player)
	
func resetGame():
	timer = 0
	currentHealth = maxHealth
	currentMinigame = ""
	spawnedHoles = 0
	
	if InteractablesNode == null: return
	for child in InteractablesNode.get_children():
		if child.get_meta("Clone"):
			child.queue_free()
	
func endGame():
	if gameActive == false: return
	
	gameActive = false
	
	if currentHealth <= 0:
		# died from sinking, not cannon
		var shipLevel:Node2D = currentScene.get_node("ShipNode/ShipMask/ShipLevel")
		
		var newPos:Vector2 = shipLevel.position+Vector2(0,100)
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_parallel()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(shipLevel,"position",newPos,0.6)
		tween.tween_property(shipLevel,"rotation_degrees",-13,0.6)
		await get_tree().create_timer(0.4,true).timeout
	
	await get_tree().create_timer(0.2,true).timeout
	get_tree().paused = true
	get_tree().current_scene.modulate = Color(0.502, 0.275, 0.275, 1.0)
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_parallel()
	#tween.tween_property(currentPlayer.playerCamera,"zoom",Vector2(2,2),0.35)
	#currentPlayer.playerCamera.zoom = Vector2(2,2)
	
	await get_tree().create_timer(0.75,true).timeout
	get_tree().change_scene_to_file("res://Scenes/death_screen.tscn")
	get_tree().paused = false
	# the game freezes, so if you get blown up, it'll freeze on that frame and its funny
	
	fadeToBlack(0)

	fadeFromBlack(0.25)
	resetGame()
	
func spawnHole():
	var holeArea = currentScene.get_node("ShipNode").get_node("ShipMask").get_node("ShipLevel").get_node("HoleArea")
	var holeShape = holeArea.get_node("CollisionShape2D")
	var spawnShape:RectangleShape2D = holeShape.shape as RectangleShape2D
	var spawnSize:Vector2 = spawnShape.size
	
	var ranX = randf_range(-spawnSize.x/2,spawnSize.x/2)
	var ranY = randf_range(-spawnSize.y/2,spawnSize.y/2)
	var randomLocalPos:Vector2 = Vector2(ranX,ranY)
	var randomGlobalPos = holeShape.to_global(randomLocalPos)
	
	var targetClone:Node2D = targetScene.instantiate()
	targetClone.position = currentScene.get_node("ShipNode/ShipMask/ShipLevel").to_local(randomGlobalPos)
	currentScene.get_node("ShipNode/ShipMask/ShipLevel").add_child(targetClone)
	
	await get_tree().create_timer(1.5,false).timeout

	var holeClone:Node2D = holeScene.instantiate()
	if not is_instance_valid(holeClone): return
	if not is_instance_valid(InteractablesNode): return
	holeClone.position = InteractablesNode.to_local(randomGlobalPos+Vector2(0,20))
	var holeIcon:TextureRect = holeClone.get_node("HoleIcon")
	
	var randomScale = randf_range(0.9, 1.4)*holeIcon.scale
	holeIcon.scale = randomScale
	holeIcon.rotation = randf_range(-360,360)
	holeClone.set_meta("Clone",true)
	
	InteractablesNode.add_child(holeClone)
	currentHealth -= 5
	
	var hitbox:Area2D = targetClone.get_node("Hitbox")
	for body in hitbox.get_overlapping_bodies():
		if body.name == "Player":
			endGame()
			return
		
	
func richTextWavy(text:String):
	return "[shake rate="+str(currentShakeRate)+" level="+str(currentShakeLevel)+" connected=1]"+text+"[/shake]"
