extends Node
class_name Player

var id: int
var username: String
var password: String
var salt: String # used for password hashing
var email: String
var created_at: String
var temp: TempPlayer

func _ready():
	temp = TempPlayer.new()
