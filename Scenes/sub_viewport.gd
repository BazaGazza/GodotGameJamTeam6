extends SubViewport

func _ready():
	world_2d = get_tree().root.world_2d
	$ViewportCamera.make_current()

func _process(_delta):
	var player = GameManager.currentPlayer
	if player:
		$ViewportCamera.global_position = player.global_position
