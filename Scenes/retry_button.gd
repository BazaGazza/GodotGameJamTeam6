extends Button
func _on_pressed() -> void:
	GameManager.fadeToBlack(0.5)
	await get_tree().create_timer(0.5,false).timeout
	GameManager.fadeFromBlack(0.5)
	GameManager.resetGame()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	GameManager.gameActive = true
