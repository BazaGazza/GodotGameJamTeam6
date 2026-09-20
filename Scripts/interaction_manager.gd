extends Node2D
signal hideOtherPrompts

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var currentInteractable: Interactable = null
var minigameScript = null

func showPrompt(newInteractable):
	hideOtherPrompts.emit(newInteractable)
	currentInteractable = newInteractable
	
func hidePrompt(hiddenPrompt):
	if currentInteractable == hiddenPrompt:
		currentInteractable = null



func _input(event):
	if event.is_action_pressed("interact") and currentInteractable:
		var type: String = currentInteractable.interactType
		print("Interacted with: "+type)
		
		#hides the prompt just selected
		currentInteractable = null
		hideOtherPrompts.emit(null)
		
		if type == "GoDown":
			GameManager.goDown()
		elif type == "GoUp":
			GameManager.goUp()
		else:
			minigameScript.startGame(type)
		#hardcode the up and down, but otherwise i think i would want a way to store functions in a dictionary
		# and call the function for the minigame from there
		
		
