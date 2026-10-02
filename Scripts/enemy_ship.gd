class_name EnemyShip
extends Node2D

var health = 2.0
var attackOdds = 0.1
@onready var sprite:Sprite2D = $Sprite2D
@onready var blur:Sprite2D = $Blur

var originalPos:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	originalPos = sprite.position
	sprite.position = originalPos + Vector2(200,0)
	sprite.modulate.a = 0
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_parallel()
	tween.tween_property(sprite,"modulate:a",1,0.3)
	tween.tween_property(sprite,"position",originalPos,0.3)
	
	blur.visible = true
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_loops(6)
	blur.modulate.a = 0
	tween.tween_property(blur,"modulate:a",1,0.025)
	tween.tween_property(blur,"modulate:a",0,0.025)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func damage():
	health -= 1
	
	blur.visible = true
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_loops(6)
	sprite.modulate.a = 0
	tween.tween_property(blur,"modulate:a",0,0.025)
	tween.tween_property(blur,"modulate:a",0.5,0.025)
	await get_tree().create_timer(0.3,false).timeout
	blur.visible = false
	if health == 1:
		tween.kill()
		tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(sprite,"modulate:a",0.5,0.4)
	elif health == 0:
		GameManager.spawnedShips -= 1
		GameManager.scheduleShipSpawn()
		self.queue_free()
