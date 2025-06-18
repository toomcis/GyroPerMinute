extends Control

@onready var IPLabel = $RichTextLabel

var multiplayer_peer = ENetMultiplayerPeer.new()
const PORT = 7183
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

	print("Server listening on port %d" % PORT)
	
	IPLabel.text = "Number of players = " + str(len(ListOfPlayers) - 1)# Add IP to connect instead of number of players

func _process(delta):
	pass

func _on_peer_connected(id):
	print("Peer connected: %s" % id)
	ListOfPlayers.append(id)
	var NewPlayer = load("res://Player.tscn").instantiate()
	add_child(NewPlayer)
	NewPlayer.position = get_viewport().size / 2

func _on_peer_disconnected(id):
	print("⚠️ Peer disconnected: %s" % id)

func getPlayerOffID(id):
	return get_child(ListOfPlayers.find(id))	

@rpc("any_peer")
func sentPlayerColor(sentColor):
	var player = getPlayerOffID(multiplayer.get_remote_sender_id())
	player.get_child(0).texture.gradient.set_color(0, sentColor)
	player.get_child(0).get_child(0).default_color = sentColor

@rpc("any_peer")
func send_gyro(GyroData):
	
	var DPI = (get_viewport().size.x + get_viewport().size.y) / 160
	var player = getPlayerOffID(multiplayer.get_remote_sender_id())
	
	if player.position.x >= get_viewport().size.x:
		player.position.x = 0
	elif player.position.x <= 0:
		player.position.x = get_viewport().size.x
	
	if player.position.y >= get_viewport().size.y:
		player.position.y = 0
	elif player.position.y <= 0:
		player.position.y = get_viewport().size.y
	
	
	player.position.x += GyroData.z * -DPI
	player.position.y += GyroData.x * -DPI 

@rpc("any_peer")
func send_print():
	print("Recieved a signal")
