extends Node2D


# Called when the node enters the scene tree for the first time.

@onready var explosionSprite:AnimatedSprite2D = $Explosion
@onready var targetSprite:Sprite2D = $Target

var originalScale:Vector2


func _ready() -> void:
	originalScale = targetSprite.scale
	
	targetSprite.scale = Vector2.ZERO
	targetSprite.modulate.a = 0
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_parallel()
	tween.tween_property(targetSprite,"modulate:a",1,0.6)
	tween.tween_property(targetSprite,"scale",originalScale,0.6)
	
	await get_tree().create_timer(0.5).timeout
	var blinkTween = create_tween()
	blinkTween.set_loops()
	blinkTween.tween_property(targetSprite, "modulate:a", 0.2, 0.25)
	blinkTween.tween_property(targetSprite, "modulate:a", 1.0, 0.25)
	await get_tree().create_timer(1.0).timeout
	blinkTween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_parallel()
	tween.tween_property(targetSprite,"modulate:a",0,0.15)
	tween.tween_property(targetSprite,"scale",originalScale*2,0.15)

	explosionSprite.visible = true
	explosionSprite.play("explode")
	await get_tree().create_timer(0.25).timeout
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(explosionSprite,"modulate:a",0,0.4)
	
	await get_tree().create_timer(0.4).timeout
	self.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
