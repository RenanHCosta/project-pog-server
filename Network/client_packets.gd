extends Node

# CONTAINS FUNCTIONS RELATIVE TO CLIENT PACKETS
# FUNCTIONS THAT SERVER RECEIVES FROM CLIENT

var Utils = preload("res://utils.gd")

func _ready():
	Utils = Utils.new()
	
func start():
	get_tree().set_multiplayer(Network.multiplayer_api, self.get_path())

@rpc("any_peer")
func MovementInfo(username, direction, velocity):
	var player_id = Network.multiplayer_api.get_remote_sender_id()
	
	for i in range(Globals.Players.size()):
		if Globals.Players[i] != null:
			if Globals.Players[i].network_id != player_id:
				ServerPackets.ProcessMovement.rpc_id(Globals.Players[i].network_id, username, direction, velocity)

@rpc("any_peer")
func TryLogin(username: String, password: String):
	var player_id = Network.multiplayer_api.get_remote_sender_id()
	
	# TODO: Check user is already logged in
	
	if username.strip_edges().length() < 4 or password.strip_edges().length() < 4:
		print("Erro - O nome da conta deve ter entre 3 e 12 caracteres. Sua senha deve ter entre 3 e 20 caracteres.")
		ServerPackets.AlertMsg.rpc_id(player_id, "Erro - O nome da conta deve ter entre 3 e 12 caracteres. Sua senha deve ter entre 3 e 20 caracteres.")
		return
		
	if username.strip_edges().length() > Constants.ACCOUNT_LENGTH or password.strip_edges().length() > Constants.NAME_LENGTH:
		print("Erro - O nome da conta deve ter entre 3 e 12 caracteres. Sua senha deve ter entre 3 e 20 caracteres.")
		ServerPackets.AlertMsg.rpc_id(player_id, "Erro - O nome da conta deve ter entre 3 e 12 caracteres. Sua senha deve ter entre 3 e 20 caracteres.")
		return
	
	if !Utils.is_valid_nickname(username):
		print("Erro - Nome inválido, somente letras, números, espaços e _ são permitidos em nomes.")
		ServerPackets.AlertMsg.rpc_id(player_id, "Erro - Nome inválido, somente letras, números, espaços e _ são permitidos em nomes.")		
		return
		
	if !Database.AccountExist(username.strip_edges()):
		ServerPackets.AlertMsg.rpc_id(player_id, "Erro - Este login não existe.")
		return
		
	if !Database.PasswordOK(username, password):
		ServerPackets.AlertMsg.rpc_id(player_id, "Erro - Senha incorreta.")
		return
		
	# Send Login Ok
	var player_object = Database.LoadPlayer(username)
	var player = Player.new(player_id, player_object.id, player_object.username, player_object.email, player_object.created_at)
	player.temp.isPlaying = true
	
	var player_index = null
	
	for i in range(Globals.Players.size()):
		if Globals.Players[i] == null:
			player_index = i
			Globals.Players[i] = player
			break
	
	ServerPackets.LoginOk.rpc_id(player_id, player_index)
	
	var online_players = []
	for i in range(Globals.Players.size()):
		if Globals.Players[i] != null:
			online_players.append(Utils.PlayerData(i))
			
			if i != player_index:
				ServerPackets.PlayerDataPacket.rpc_id(Globals.Players[i].network_id, player_index, Utils.PlayerData(player_index))
		else:
			online_players.append(null)
			
	
	ServerPackets.SyncPlayers.rpc_id(player_id, online_players)

@rpc("any_peer")
func TryCreateAccount(username: String, password: String):
	var player_id = Network.multiplayer_api.get_remote_sender_id()
	
	if username.strip_edges().length() < 4 or password.strip_edges().length() < 4:
		print("Erro - O nome da conta deve ter entre 3 e 12 caracteres. Sua senha deve ter entre 3 e 20 caracteres.")
		ServerPackets.AlertMsg.rpc_id(player_id, "Erro - O nome da conta deve ter entre 3 e 12 caracteres. Sua senha deve ter entre 3 e 20 caracteres.")
		return
		
	if username.strip_edges().length() > Constants.ACCOUNT_LENGTH or password.strip_edges().length() > Constants.NAME_LENGTH:
		print("Erro - O nome da conta deve ter entre 3 e 12 caracteres. Sua senha deve ter entre 3 e 20 caracteres.")
		ServerPackets.AlertMsg.rpc_id(player_id, "Erro - O nome da conta deve ter entre 3 e 12 caracteres. Sua senha deve ter entre 3 e 20 caracteres.")
		return
	
	if !Utils.is_valid_nickname(username):
		print("Erro - Nome inválido, somente letras, números, espaços e _ são permitidos em nomes.")
		ServerPackets.AlertMsg.rpc_id(player_id, "Erro - Nome inválido, somente letras, números, espaços e _ são permitidos em nomes.")		
		return
	
	if !Database.AccountExist(username.strip_edges()):
		if Database.AddAccount(username.strip_edges(), password):
			ServerPackets.AlertMsg.rpc_id(player_id, "Conta " + username + " criada.")					
			print("Conta " + username + " criada.")
			# TODO: send login ok
		else:
			ServerPackets.AlertMsg.rpc_id(player_id, "Erro ao criar a conta. Entre em contato em ", Constants.WEBSITE)	
			print("Erro ao criar a conta. Entre em contato em ", Constants.WEBSITE)
	else:
		ServerPackets.AlertMsg.rpc_id(player_id, "Já existe uma conta com esse nome de usuário.")			
		print("Já existe uma conta com esse nome de usuário.")
		
@rpc("any_peer", "unreliable")
func update_transform(_direction, _position):
	var player_id = Network.multiplayer_api.get_remote_sender_id()
	ServerPackets.update_player_transform.rpc(player_id, _direction, _position)

@rpc("any_peer")
func ping():
	print("Ping received")
