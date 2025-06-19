extends Control

@onready var MenuLabel = $Nodes/Label
@onready var DPI = (get_viewport().size.x + get_viewport().size.y)

const PORT = 7183
var multiplayer_peer = ENetMultiplayerPeer.new()
var ListOfPlayers = [0]
var ServerStarted = false

func _ready():
	
	var err = multiplayer_peer.create_server(PORT)
	if err != OK:
		print("Error starting Game server: ", err)
		return
	
	multiplayer.multiplayer_peer = multiplayer_peer

	# Connect to multiplayer signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	ServerStarted = true


func _process(delta):
	pass

func _on_peer_connected(id):
	var CurrentPlayerIndex = ListOfPlayers.size()
	print("Peer connected: %s" % id)
	ListOfPlayers.append(id)
	var NewPlayer = load("res://Player/Player.tscn").instantiate()
	add_child(NewPlayer)
	NewPlayer.position = get_viewport().size / 2
	if ServerStarted:
		MenuLabel.text = "Player " + str(CurrentPlayerIndex) + " disconnected"
	

func _on_peer_disconnected(id):
	print("Peer disconnected: %s" % id)
	var indexOfDisconnectedPlayer = ListOfPlayers.find(id)
	ListOfPlayers.remove_at(indexOfDisconnectedPlayer)
	print(get_child(indexOfDisconnectedPlayer))
	remove_child(get_child(indexOfDisconnectedPlayer))
	if ServerStarted:
		MenuLabel.text = "Player " + str(indexOfDisconnectedPlayer) + " disconnected"

func getPlayerOffID(id):
	return get_child(ListOfPlayers.find(id))	

@rpc("any_peer")
func sentPlayerColor(sentColor):
	var player = getPlayerOffID(multiplayer.get_remote_sender_id())
	var mesh = player.get_child(0)
	var line = mesh.get_child(0)
	
	var new_gradient = mesh.texture.gradient.duplicate()
	mesh.texture.gradient = new_gradient
	new_gradient.set_color(0, sentColor)

	var mew_gradient = line.gradient.duplicate()
	line.gradient = new_gradient
	new_gradient.set_color(0, sentColor)

	print(ListOfPlayers.find(multiplayer.get_remote_sender_id()))

@rpc("any_peer")
func getInfo(_information):
	pass

@rpc("any_peer")
func send_gyro(GyroData):
	
	var moveDPI = DPI / 140
	var player = getPlayerOffID(multiplayer.get_remote_sender_id())
	
	player.rotation += GyroData.y
	if player.rotation >= 360 or player.rotation <= -360:
		player.rotation = 0
	print(player.rotation)
	
	if player.position.x >= get_viewport().size.x:
		player.position.x = 0
	elif player.position.x <= 0:
		player.position.x = get_viewport().size.x
	
	if player.position.y >= get_viewport().size.y:
		player.position.y = 0
	elif player.position.y <= 0:
		player.position.y = get_viewport().size.y
	
	
	player.position.x += GyroData.z * -moveDPI
	player.position.y += GyroData.x * -moveDPI 

@rpc("any_peer")
func send_print():
	print("Recieved a signal, meaning proper connection was established!")
	getInfo.rpc_id(multiplayer.get_remote_sender_id(), "Established connection!")


func _on_resized() -> void:
	DPI = (get_viewport().size.x + get_viewport().size.y)
	if ServerStarted:
		MenuLabel.text = "Game resized, changed DPI to " + str(DPI)


func _on_start_game_body_entered(body: Node2D) -> void:
	print(body)
	MenuLabel.text = "Body " + str(body) + " entered start game area!"
