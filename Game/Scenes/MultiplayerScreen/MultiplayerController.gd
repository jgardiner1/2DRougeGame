extends Control

@export var address = "127.0.0.1"
@export var PORT = 4433

var peer

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	if "--server" in OS.get_cmdline_args():
		host_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func host_game():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 4)
	
	if error != OK:
		print("Cannot host: ", error)
		return
		
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players...")

# Gets called on the server and clients
func peer_connected(id):
	print("Player Connected: ", id)

# Gets called on the server and clients
func peer_disconnected(id):
	print("Player Disconnected: ", id)

# Gets called on clients only
func connected_to_server():
	print("Connected to Server")
	send_player_information.rpc_id(1, $NameEntry.text, multiplayer.get_unique_id())

# Gets called on clients only
func connection_failed():
	print("Connection Failed")


@rpc("any_peer")
func send_player_information(player_name, id):
	if not GameManager.players.has(id):
		GameManager.players[id] = {
			"player_name": player_name,
			"id": id,
		}
		print("Player ", GameManager.players[id].player_name, " succesfully added")
	
	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_information.rpc(GameManager.players[i].player_name, i)
	
	print("In send player info. list size: ", GameManager.players.size())

@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://Scenes/Menus/World.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_host_button_down():
	host_game()
	send_player_information($NameEntry.text, multiplayer.get_unique_id())


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, PORT)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

func _on_start_game_button_down():
	start_game.rpc()

func _on_back_button_down():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
