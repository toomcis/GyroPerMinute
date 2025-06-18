extends Control

@onready var text_label = $RichTextLabel
const PORT = 7183
var websocket_peer := WebSocketMultiplayerPeer.new()

func _ready():
	var err = websocket_peer.create_server(PORT)
	if err != OK:
		print("Error starting WebSocket server: ", err)
		return
	
	# Assign the multiplayer peer to the scene
	multiplayer.multiplayer_peer = websocket_peer

	# Connect to multiplayer signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	print("✅ WebSocket server listening on port %d" % PORT)

func _process(delta):
	websocket_peer.poll()

func _on_peer_connected(id):
	print("✅ Peer connected: %s" % id)

func _on_peer_disconnected(id):
	print("⚠️ Peer disconnected: %s" % id)

@rpc()
func send_string(gyro: Vector3):
	print("📡 Received string data: ", gyro)

remote func test(t):
  print(t)
