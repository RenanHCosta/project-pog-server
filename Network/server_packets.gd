extends Node

# CONTAINS FUNCTIONS RELATIVE TO SERVER PACKETS
# FUNCTIONS THAT SERVER SENDS TO CLIENT

	
func start():
	get_tree().set_multiplayer(Network.multiplayer_api, self.get_path())
		

@rpc
func ChatMessage(_msg):
	pass # only implemented in client (but still has to exist here)

@rpc
func ProcessAttack(_username, _is_attacking):
	pass # only implemented in client (but still has to exist here)
	
@rpc
func ProcessMovement(_direction, _velocity):
	pass # only implemented in client (but still has to exist here)

@rpc
func PlayerDataPacket(_player_index, _player_data):
	pass # only implemented in client (but still has to exist here)

@rpc
func SyncPlayers(_players):
	pass # only implemented in client (but still has to exist here)

@rpc
func LoginOk(_index):
	pass # only implemented in client (but still has to exist here)
	
@rpc 
func AlertMsg(_msg):
	pass # only implemented in client (but still has to exist here)

@rpc
func delete_obj(_id):
	pass # only implemented in client (but still has to exist here)
	
@rpc
func instance_player(_id, _location):
	pass # only implemented in client (but still has to exist here)

@rpc
func update_player_transform(_player_id, _direction, _position):
	pass # only implemented in client (but still has to exist here)
