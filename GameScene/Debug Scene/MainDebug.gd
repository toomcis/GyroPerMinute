extends Control

@onready var MenuLabel = $Nodes/Label
@onready var DPI = (get_viewport().size.x + get_viewport().size.y)

const PORT = 7183
var secondsPassed = 0
var ServerStarted = false
var multiplayer_peer = ENetMultiplayerPeer.new()
var gameStarted = ""


var playersInStart = [0]
var playersInSettings = [0]

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
	var CurrentPlayerIndex = Globals.ListOfPlayers.size()
	print("Peer connected: %s" % id)
	Globals.ListOfPlayers.append(id)
	var NewPlayer = load("res://Player/Player.tscn").instantiate()
	add_child(NewPlayer)
	NewPlayer.position = get_viewport().size / 2
	if ServerStarted:
		MenuLabel.text = "Player " + str(CurrentPlayerIndex) + " connected to server!"
	

func _on_peer_disconnected(id):
	print("Peer disconnected: %s" % id)
	var indexOfDisconnectedPlayer = Globals.ListOfPlayers.find(id)
	Globals.ListOfPlayers.remove_at(indexOfDisconnectedPlayer)
	print(get_child(indexOfDisconnectedPlayer))
	remove_child(get_child(indexOfDisconnectedPlayer))
	Globals.ListOfPlayerColors.remove_at(indexOfDisconnectedPlayer)
	if ServerStarted:
		MenuLabel.text = "Player " + str(indexOfDisconnectedPlayer) + " disconnected"
		

func getPlayerOffID(id):
	return get_child(Globals.ListOfPlayers.find(id))	

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

	print(Globals.ListOfPlayers.find(multiplayer.get_remote_sender_id()))
	Globals.ListOfPlayerColors.append(sentColor)

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
	var player = get_children().find(body)
	playersInStart.append(Globals.ListOfPlayers[player])
	print(playersInStart)
	MenuLabel.text = "Player " + str(player) + " entered start game area!"
	
	if Globals.ListOfPlayers == playersInStart and Globals.ListOfPlayers != [0]:
		print("Starting game!")
		MenuLabel.text = "All players in start, starting soon!"
		secondsPassed = 0
		$"Nodes/Start Game/CountDown".start()

func gameStart(gameMode):
	MenuLabel.text = str(gameMode) + " started!"
	#get_tree().change_scene_to_file("")

func _on_start_game_body_exited(body: Node2D) -> void:
	var player = get_children().find(body)
	playersInStart.erase(Globals.ListOfPlayers[player])
	print(playersInStart)
	MenuLabel.text = "Player " + str(player) + " exited start game area!"


func _on_count_down_timeout() -> void:
	secondsPassed += 1
	MenuLabel.text = str(secondsPassed)
	if not secondsPassed > 5:
		$"Nodes/Start Game/CountDown".start()
	else:
		gameStart(gameStarted)
