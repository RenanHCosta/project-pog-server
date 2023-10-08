extends Node

# call_local allows the server to run the rpc function on itself and also on clients
# any_peer allows the clients to run the rpc function on the server
# reliable means the network packets will not be lost, packets will be sent until received and acknowledged

var server = ENetMultiplayerPeer.new()
var multiplayer_api : MultiplayerAPI
const PORT = 4242
const MAX_PLAYERS = 15

const INITIAL_PLAYER_POSITION = Vector2(200, 200)

func _ready():
	server.peer_connected.connect(_player_connected)
	server.peer_disconnected.connect(_player_disconnected)
	multiplayer_api = MultiplayerAPI.create_default_interface()
	
	var err = server.create_server(PORT, MAX_PLAYERS)
	if err != OK:
		print("Unable to start server")
		return
	server.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	get_tree().set_multiplayer(multiplayer_api, self.get_path())
	multiplayer_api.multiplayer_peer = server
	print("Server created")
	
func _process(_delta):
	if multiplayer_api.has_multiplayer_peer():
		multiplayer_api.poll()
	

func _player_connected(id):
	print("Player connected: ", id)
	# The connect signal fires before the client is added to the connected
	# clients in multiplayer.get_peers(), so we wait for a moment.
	await get_tree().create_timer(1).timeout
	instance_player.rpc(id, INITIAL_PLAYER_POSITION)
	
func _player_disconnected(id):
	print("Player disconnected: ", id)
	delete_obj.rpc(id)
	
@rpc
func delete_obj(id):
	pass # only implemented in client (but still has to exist here)
	
@rpc
func instance_player(_id, _location):
	pass # only implemented in client (but still has to exist here)

@rpc("any_peer", "unreliable")
func update_transform(_direction, _position):
	var player_id = multiplayer_api.get_remote_sender_id()
	update_player_transform.rpc(player_id, _direction, _position)
	
@rpc()
func update_player_transform(player_id, direction, position):
	pass # only implemented in client (but still has to exist here)
