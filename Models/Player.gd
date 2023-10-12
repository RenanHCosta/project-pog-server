extends Node
class_name Player

var id: int
var username: String
var password: String
var salt: String # used for password hashing
var email: String
var created_at: String
var temp = TempPlayer.new()
var network_id: int

# Construtor personalizado
func _init(_network_id, _id, _username, _email, _created_at):
	self.network_id = _network_id
	self.id = _id
	self.username = _username
	self.email = _email
	self.created_at = _created_at
