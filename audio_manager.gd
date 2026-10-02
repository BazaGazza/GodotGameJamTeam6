extends Node

@onready var menuSong: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var mainSong: AudioStreamPlayer = AudioStreamPlayer.new()

var randomSfx = {
	"HammerNail" = 0.1,
	"RamSound" = 0.1,
}

var sfx = {
	"CannonballCrash" = preload("res://Audio/CannonballCrash.wav"),
	"ShipSpawn" = preload("res://Audio/ShipSpawn.wav"),
	"Warning" = preload("res://Audio/Warning.wav"),
	"FireCannon" = preload("res://Audio/FireCannon.wav"),
	"DragPlank" = preload("res://Audio/DragPlank.wav"),
	"HammerNail" = preload("res://Audio/HammerNail.wav"),
	"DistantCannon" = preload("res://Audio/DistantCannon.wav"),
	"RamSound" = preload("res://Audio/RamSound.wav"),
	"PowderSound" = preload("res://Audio/PowderSound.wav"),
	"PlankPlace" = preload("res://Audio/PlankPlace.wav"),
	"LoadCannon" = preload("res://Audio/LoadCannon.wav")
}



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menuSong.name = "MenuSong"
	add_child(menuSong)
	menuSong.stream = preload("res://Audio/Main Theme Ship.wav")
	#menuSong.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	#menuSong.stream.loop_end = int(menuSong.stream.get_length() * menuSong.stream.mix_rate)
	
	add_child(mainSong)
	mainSong.name = "GameplaySong"
	mainSong.stream = preload("res://Audio/gameplay_music.ogg")
	#mainSong.stream.loop = true

var defaultVolumes = {
	"MenuSong":0,
	"GameplaySong":-3,
	"CannonballCrash": 5,
	"Warning": 1,
	"DistantCannon": 15,
	
	"DragPlank": 5,
	"FireCannon": 4,
}

func playSfx(audioName: String,soundPosition = null):
	var stream: AudioStream = sfx.get(audioName)
	if stream == null: return
	
	var streamPlayer
	if soundPosition != null:
		streamPlayer = AudioStreamPlayer2D.new()
		streamPlayer.position = soundPosition
	else:
		streamPlayer = AudioStreamPlayer.new()

	if audioName in randomSfx:
		streamPlayer.pitch_scale = 1 + randf_range(-randomSfx[audioName],randomSfx[audioName])

	streamPlayer.stream = stream
	streamPlayer.volume_db = defaultVolumes.get(audioName,0)
	streamPlayer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(streamPlayer)
	streamPlayer.finished.connect(streamPlayer.queue_free)
	streamPlayer.play()

func fadeIn(audio:AudioStreamPlayer,fadeTime = 1):
	var defaultVol = defaultVolumes.get(audio.name,0)
	audio.process_mode = Node.PROCESS_MODE_ALWAYS
	audio.volume_db = -40
	audio.play()
	var tween = create_tween()
	tween.tween_property(audio, "volume_db",defaultVol,fadeTime)
	
func fadeOut(audio:AudioStreamPlayer,fadeTime = 1):
	audio.process_mode = Node.PROCESS_MODE_ALWAYS
	var tween = create_tween()
	tween.tween_property(audio, "volume_db", -40.0, fadeTime)
	tween.tween_callback(audio.stop)

func playMenuSong(fadeTime = 1):
	fadeIn(menuSong,fadeTime)
	
func stopMenuSong(fadeTime = 1):
	fadeOut(menuSong,fadeTime)
	
func playMainSong(fadeTime = 1):
	mainSong.pitch_scale = 1
	fadeIn(mainSong,fadeTime)
	
func stopMainSong(fadeTime = 1):
	fadeOut(mainSong,fadeTime)

func songDeath():
	mainSong.pitch_scale = 0.3
