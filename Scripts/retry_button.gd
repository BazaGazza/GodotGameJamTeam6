extends Button

@onready var board:TextureRect = $TextureRect
@onready var glow:TextureRect = $Glow

func _on_pressed() -> void:
	GameManager.fadeToBlack(0.5)
	await get_tree().create_timer(0.5,false).timeout
	GameManager.fadeFromBlack(0.5)
	GameManager.resetGame()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	GameManager.gameActive = true
	
var glowTween:Tween

func _ready() -> void:
	await get_tree().process_frame
	GameManager.fadeFromBlack(2)
	glow.modulate.a = 0
	
	var originalPos:Vector2 = self.position
	
	var loopTween = create_tween()
	loopTween.set_trans(Tween.TRANS_SINE)
	loopTween.set_ease(Tween.EASE_IN_OUT)
	loopTween.set_loops()
	loopTween.tween_property(self, "position",originalPos+Vector2(0,-16), 2)
	loopTween.tween_property(self, "position",originalPos, 2)

func _on_mouse_entered() -> void:
	glowTween = create_tween()
	glowTween.set_trans(Tween.TRANS_SINE)
	glowTween.set_ease(Tween.EASE_OUT)
	glowTween.tween_property(glow, "modulate:a",1, 0.5)
func _on_mouse_exited() -> void:
	if glowTween: glowTween.kill()

	glowTween = create_tween()
	glowTween.set_trans(Tween.TRANS_SINE)
	glowTween.set_ease(Tween.EASE_OUT)
	glowTween.tween_property(glow, "modulate:a",0, 0.2)
