class_name Interactable
extends Area2D

@export var interactRadius = 1.00
@export var interactType = "Nothing"
@onready var extraIcon = get_node_or_null("ExtraIcon")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	InteractionManager.hideOtherPrompts.connect(_on_toggle_prompt)
	if extraIcon:
		extraIcon.visible = false
	$Icon.hide()
	$CollisionShape2D.scale = Vector2(interactRadius, interactRadius)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_toggle_prompt(newInteractable):
	if newInteractable != self:
		if extraIcon:
			extraIcon.visible = false
		$Icon.hide()

func _on_body_entered(body: Node2D) -> void:
	if body is not Player: return
	if extraIcon:
		extraIcon.visible = true
	$Icon.show()
	InteractionManager.showPrompt(self)

func _on_body_exited(body: Node2D) -> void:
	if extraIcon:
		extraIcon.visible = false
	$Icon.hide()
	InteractionManager.hidePrompt(self)
