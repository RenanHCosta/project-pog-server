extends Node

# call_local allows the server to run the rpc function on itself and also on clients
# any_peer allows the clients to run the rpc function on the server
# reliable means the network packets will not be lost, packets will be sent until received and acknowledged

var server = ENetMultiplayerPeer.new()
var multiplayer_api : MultiplayerAPI

func _ready():
	server.peer_connected.connect(_player_connected)
	server.peer_disconnected.connect(_player_disconnected)
	multiplayer_api = MultiplayerAPI.create_default_interface()
	
	var err = server.create_server(Constants.PORT, Constants.MAX_PLAYERS)
	if err != OK:
		print("Unable to start server")
		return
	server.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	get_tree().set_multiplayer(multiplayer_api, self.get_path())
	ClientPackets.start()
	ServerPackets.start()
	multiplayer_api.multiplayer_peer = server
	print("🔥 Server started on port " + str(Constants.PORT))

func _process(_delta):
	if multiplayer_api.has_multiplayer_peer():
		multiplayer_api.poll()

func _player_connected(id):
	print("[" + str(id) + "] Connection received from ", server.get_peer(id).get_remote_address())
	# The connect signal fires before the client is added to the connected
	# clients in multiplayer.get_peers(), so we wait for a moment.
	await get_tree().create_timer(1).timeout
	ServerPackets.instance_player.rpc(id, Constants.INITIAL_PLAYER_POSITION)

func _player_disconnected(id):
	print("[" + str(id) + "] Connection disconnected")
	ServerPackets.delete_obj.rpc(id)
