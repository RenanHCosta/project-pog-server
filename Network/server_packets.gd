extends Node

# CONTAINS FUNCTIONS RELATIVE TO SERVER PACKETS
# FUNCTIONS THAT SERVER SENDS TO CLIENT

func start():
	get_tree().set_multiplayer(Network.multiplayer_api, self.get_path())
	
@rpc
func delete_obj(_id):
	pass # only implemented in client (but still has to exist here)
	
@rpc
func instance_player(id, location):
	pass # only implemented in client (but still has to exist here)

@rpc
func update_player_transform(_player_id, _direction, _position):
	pass # only implemented in client (but still has to exist here)
