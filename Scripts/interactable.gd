class_name Interactable
extends Area2D

@export var interactRadius = 1.00
@export var interactType = "Nothing"
@onready var extraIcon = get_node_or_null("ExtraIcon")

var currentPlayer:Player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	InteractionManager.hideOtherPrompts.connect(_on_toggle_prompt)
	if extraIcon:
		extraIcon.visible = false
	$Icon.hide()
	$CollisionShape2D.scale = Vector2(interactRadius, interactRadius)
	
	if GameManager.currentPlayer:
		currentPlayer = GameManager.currentPlayer
	else:
		GameManager.playerReady.connect(func(newPlayer):currentPlayer = newPlayer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func visualShow():

	if currentPlayer.doingMinigame == true: return
	if self.get_meta("Cooldown",false) == true: return
	
	if extraIcon:
		extraIcon.visible = true
	$Icon.show()

func _on_toggle_prompt(newInteractable):
	if newInteractable != self:
		if extraIcon:
			extraIcon.visible = false
		$Icon.hide()
	elif $Icon.visible == false:
		visualShow()

func _on_body_entered(body: Node2D) -> void:
	if body is not Player: return
	visualShow()
	InteractionManager.showPrompt(self)

func _on_body_exited(body: Node2D) -> void:
	if extraIcon:
		extraIcon.visible = false
	$Icon.hide()
	InteractionManager.hidePrompt(self)
