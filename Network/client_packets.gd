extends Node

# CONTAINS FUNCTIONS RELATIVE TO CLIENT PACKETS
# FUNCTIONS THAT SERVER RECEIVES FROM CLIENT

var Utils = preload("res://utils.gd")

func _ready():
	Utils = Utils.new()
	
func start():
	get_tree().set_multiplayer(Network.multiplayer_api, self.get_path())
	
@rpc("any_peer")
func TryCreateAccount(username: String, password: String):
	# TODO: replace print with alert msgs to the client
	# TODO: Check Client Version
	
	if username.strip_edges().length() > Constants.ACCOUNT_LENGTH or password.strip_edges().length() > Constants.NAME_LENGTH:
		print("Erro - O nome da conta deve ter entre 3 e 12 caracteres. Sua senha deve ter entre 3 e 20 caracteres.")
		return
	
	if !Utils.is_valid_nickname(username):
		print("Erro - Nome inválido, somente letras, números, espaços e _ são permitidos em nomes.")
		return
	
	if !Database.AccountExist(username.strip_edges()):
		if Database.AddAccount(username.strip_edges(), password):
			print("Conta " + username + " criada.")
			# TODO: send login ok
		else:
			print("Erro ao criar a conta. Entre em contato em ", Constants.WEBSITE)
	else:
		print("Já existe uma conta com esse nome de usuário.")
		
@rpc("any_peer", "unreliable")
func update_transform(_direction, _position):
	var player_id = Network.multiplayer_api.get_remote_sender_id()
	ServerPackets.update_player_transform.rpc(player_id, _direction, _position)

@rpc("any_peer")
func ping():
	print("Ping received")
