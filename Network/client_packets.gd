extends Node

# CONTAINS FUNCTIONS RELATIVE TO CLIENT PACKETS
# FUNCTIONS THAT SERVER RECEIVES FROM CLIENT

func start():
	get_tree().set_multiplayer(Network.multiplayer_api, self.get_path())
	
@rpc("any_peer", "unreliable")
func update_transform(_direction, _position):
	var player_id = Network.multiplayer_api.get_remote_sender_id()
	ServerPackets.update_player_transform.rpc(player_id, _direction, _position)

@rpc("any_peer")
func ping():
	print("Ping received")
