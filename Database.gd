extends Node

var db # Database Object
var db_name = "res://DataStore/database" # Path to Database

# Called when the node enters the scene tree for the first time.
func _ready():
	db = SQLite.new()
	db.path = db_name
	print("🎲 Database initialized")
	#HandleCreateAccount("fduiashsf", "fduiashsf", "fduiashsf@ava.com")
	#HandleLogin("fduiashsf", "fduiashsf")

func AccountExist(username):
	db.open_db()
	var tableName = "accounts"
	db.query("SELECT * FROM " + tableName + " WHERE username = '" + username + "';")
	
	if (db.query_result.size() == 0):
		db.close_db()
		return false
	db.close_db()
	return true

func HandleLogin(username, password):
	db.open_db()
	var tableName = "accounts"
	db.query("SELECT * FROM " + tableName + " WHERE username = '" + username + "';")

	if (db.query_result.size() == 0):
		print("Account does not exist")
		return
	
	var account: Player = db.query_result[0]
	var retrieved_salt = account.salt
	var hashed_password = GenerateHashedPassword(password, retrieved_salt)
	var isPasswordCorrect = account.password == hashed_password
	db.close_db()
	return isPasswordCorrect

func AddAccount(username, password, email = ""):
	db.open_db()
	var tableName = "accounts"
	
	var salt = GenerateSalt()
	var hashed_password = GenerateHashedPassword(password, salt)
	
	#db.query("INSERT INTO accounts (username, password, salt, email) VALUES ('" + username + "', '" + hashed_password + "', '" + salt + "', '" + email + "');")
	if not db.insert_row(tableName, { "username": username, "password": hashed_password, "salt": salt, "email": email }):
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
