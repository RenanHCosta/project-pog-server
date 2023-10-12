extends Node

var db # Database Object
var db_name = "res://DataStore/database" # Path to Database

# Called when the node enters the scene tree for the first time.
func _ready():
	db = SQLite.new()
	db.path = db_name
	print("🎲 Database initialized")

func AccountExist(username):
	db.open_db()
	var tableName = "accounts"
	db.query("SELECT * FROM " + tableName + " WHERE username = '" + username + "';")
	
	if (db.query_result.size() == 0):
		db.close_db()
		return false
	db.close_db()
	return true

func LoadPlayer(username):
	db.open_db()
	var tableName = "accounts"
	
	db.query("SELECT * FROM " + tableName + " WHERE username = '" + username + "';")
	
	if (db.query_result.size() == 0):
		print("[LoadPlayer] Error, player não encontrado na base de dados")
		return
	
	var player = db.query_result[0]
	player.location = JSON.parse_string(player.location)
	return player
	
func SavePlayer(index):
	db.open_db()
	var tableName = "accounts"
	
	var player = Globals.Players[index]
	player.location = JSON.stringify(player.location)
	
	db.update_rows(tableName, "username = '" + player.username + "'", {
		"location": player.location
	})
	db.close_db()
	
func PasswordOK(username, password):
	db.open_db()
	var tableName = "accounts"
	var passwordField = "password"
	var saltField = "salt"
	db.query("SELECT " + passwordField + ", " + saltField + " FROM " + tableName + " WHERE username = '" + username + "';")
	
	if (db.query_result.size() == 0):
		print("Account does not exist")
		return
	
	var query_password = db.query_result[0].password
	var retrieved_salt = db.query_result[0].salt
	var hashed_password = GenerateHashedPassword(password, retrieved_salt)
	var isPasswordCorrect = hashed_password == query_password
	db.close_db()
	return isPasswordCorrect

func AddAccount(username, password, email = "", location = Constants.INITIAL_PLAYER_POSITION):
	db.open_db()
	var tableName = "accounts"
	
	var _location = JSON.stringify(location)
	var salt = GenerateSalt()
	var hashed_password = GenerateHashedPassword(password, salt)
	
	#db.query("INSERT INTO accounts (username, password, salt, email) VALUES ('" + username + "', '" + hashed_password + "', '" + salt + "', '" + email + "');")
	if not db.insert_row(tableName, { "username": username, "password": hashed_password, "salt": salt, "email": email, "location": _location }):
		print("SQL Error: " + db.error_message)
		return false
	db.close_db()
	return true

func GenerateSalt():
	randomize()
	var salt = str(randi()).sha256_text()
	print("Salt: " + salt)
	return salt
	
func GenerateHashedPassword(password, salt):
	var hashed_password = password
	var rounds = pow(2, 3)
	#print("hashed password as input: " + hashed_password)
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	
	#print("final hashed password: " + hashed_password)
	return hashed_password
