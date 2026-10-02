extends CanvasLayer

@onready var screen: ColorRect = $ColorRect
var tween: Tween

func fadeToBlack(duration: float = 0.5) -> void:
	if tween: tween.kill()
	screen.modulate.a = 0
	tween = create_tween()
	tween.tween_property(screen,"modulate:a",1,duration)

func fadeFromBlack(duration: float = 0.5) -> void:
	if tween: tween.kill()
	screen.modulate.a = 1
	tween = create_tween()
	tween.tween_property(screen,"modulate:a",0,duration)
	
