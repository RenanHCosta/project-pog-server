extends Node

func is_valid_nickname(nickname: String) -> bool:
	var valid_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 _"
	
	for chara in nickname:
		if valid_characters.find(chara) == -1:
			return false
	
	return true

func PlayerData(index):
	return {
		"id": Globals.Players[index].id,
		"network_id": Globals.Players[index].network_id,
		"username": Globals.Players[index].username,
		"created_at": Globals.Players[index].created_at,
		"location": Globals.Players[index].location
	}
