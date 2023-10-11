extends Node

func is_valid_nickname(nickname: String) -> bool:
	var valid_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 _"
	
	for char in nickname:
		if valid_characters.find(char) == -1:
			return false
	
	return true
