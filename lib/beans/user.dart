class User {
  String serverIp;
  String username;
  String password;
  String database;

  User({
    required this.serverIp,
    required this.username,
    required this.password,
    required this.database,
  });

  // Method untuk mempermudah debugging
  @override
  String toString() {
    return 'User(serverIp: $serverIp, username: $username, password: $password, database: $database)';
  }
}

// List global untuk menyimpan identitas database
List<User> userList = [];
