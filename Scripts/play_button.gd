extends Button


func _on_pressed() -> void:
	GameManager.fadeToBlack(0.5)
	await get_tree().create_timer(0.5,false).timeout
	GameManager.fadeFromBlack(0.5)
	GameManager.resetGame()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	GameManager.gameActive = true

@onready var board:Sprite2D = $Sprite2D
@onready var glow:Sprite2D = $Glow

var glowTween:Tween
var boardTween:Tween

func _ready() -> void:
	glow.modulate.a = 0
	board.rotation_degrees = 0
	board.scale = Vector2(1.00,1.00)

func _on_mouse_entered() -> void:
	glowTween = create_tween()
	glowTween.set_trans(Tween.TRANS_SINE)
	glowTween.set_ease(Tween.EASE_OUT)
	glowTween.tween_property(glow, "modulate:a",1, 0.5)
	
	boardTween = create_tween()
	boardTween.set_parallel()
	boardTween.set_trans(Tween.TRANS_BACK)
	boardTween.set_ease(Tween.EASE_OUT)
	boardTween.tween_property(board, "rotation",deg_to_rad(4), 0.2)
	boardTween.tween_property(board, "scale",Vector2(1.05,1.05), 0.2)

func _on_mouse_exited() -> void:
	if glowTween: glowTween.kill()
	if boardTween: boardTween.kill()
	
	glowTween = create_tween()
	glowTween.set_trans(Tween.TRANS_SINE)
	glowTween.set_ease(Tween.EASE_OUT)
	glowTween.tween_property(glow, "modulate:a",0, 0.2)
	boardTween = create_tween()
	boardTween.set_trans(Tween.TRANS_BACK)
	boardTween.set_ease(Tween.EASE_OUT)
	boardTween.tween_property(board, "rotation",deg_to_rad(0), 0.2)
	boardTween.tween_property(board, "scale",Vector2(1.00,1.00), 0.2)
