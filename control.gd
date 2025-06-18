extends Control

@onready var fpsLabel = $RichTextLabel
@onready var ArrowMesh = $Node2D/MeshInstance2D

var multiplayer_peer = ENetMultiplayerPeer.new()
const PORT = 7183
var timeBetweenSignals = 0.0
var ListOfPlayers = [0]

func _ready():
	
	var err = multiplayer_peer.create_server(PORT)
	if err != OK:
		print("Error starting Game server: ", err)
		return
	
	# Assign the multiplayer peer to the scene
	multiplayer.multiplayer_peer = multiplayer_peer

	# Connect to multiplayer signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	print("✅ Server listening on port %d" % PORT)
	
	ArrowMesh.position = get_viewport().size

func _process(delta):
	timeBetweenSignals += delta
	fpsLabel.text = str(Engine.get_frames_per_second())
	print(str(get_children()))
	print(ListOfPlayers)

func _on_peer_connected(id):
	print("✅ Peer connected: %s" % id)
	ListOfPlayers.append(id)
	var NewPlayer = load("res://Player.tscn")
	add_child(NewPlayer.instantiate())

func _on_peer_disconnected(id):
	print("⚠️ Peer disconnected: %s" % id)

@rpc("any_peer")
func send_string(stringData):
	print("📡 Received string data: ", stringData)

@rpc("any_peer")
func send_gyro(GyroData):
	if timeBetweenSignals >= 0.2:
		print(timeBetweenSignals)
	timeBetweenSignals = 0
	
	
	ArrowMesh.rotation += GyroData.y / 60
	
	if ArrowMesh.position.x >= get_viewport().size.x - 10:
		ArrowMesh.position.x = get_viewport().size.x - 10
	elif ArrowMesh.position.x <= 10:
		ArrowMesh.position.x = 10
	
	if ArrowMesh.position.y >= get_viewport().size.y - 10:
		ArrowMesh.position.y = get_viewport().size.y - 10
	elif ArrowMesh.position.y <= 10:
		ArrowMesh.position.y = 10
	
	ArrowMesh.position.x += GyroData.z * -8
	ArrowMesh.position.y += GyroData.x * -8

@rpc("any_peer")
func send_print():
	print("Recieved a signal")
