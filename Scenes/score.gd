extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var score = round(GameManager.timer*1 + GameManager.completedMinigames*5)
	self.text = "score: "+str(int(score))
