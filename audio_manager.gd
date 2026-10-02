extends Node

@onready var menuSong: AudioStreamPlayer = AudioStreamPlayer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(menuSong)
	menuSong.stream = preload("res://Audio/Main Theme Ship.wav")


func fadeIn(audio:AudioStreamPlayer,fadeTime = 1):
	audio.volume_db = -40
	audio.play()
	var tween = create_tween()
	tween.tween_property(audio, "volume_db",0, fadeTime)
	
func fadeOut(audio:AudioStreamPlayer,fadeTime = 1):
	var tween = create_tween()
	tween.tween_property(audio, "volume_db", -40.0, fadeTime)
	tween.tween_callback(audio.stop)

func playMenuSong():
	fadeIn(menuSong)
	
func stopMenuSong():
	fadeOut(menuSong)
