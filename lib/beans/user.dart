import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  // Save the user credentials securely
  static const _storage = FlutterSecureStorage();

  // Save user credentials to secure storage
  static Future<void> saveUserCredentials(User user) async {
    await _storage.write(key: 'serverIp', value: user.serverIp);
    await _storage.write(key: 'username', value: user.username);
    await _storage.write(key: 'password', value: user.password);
    await _storage.write(key: 'database', value: user.database);
  }

  // Retrieve user credentials from secure storage
  static Future<User?> getUserCredentials() async {
    String? serverIp = await _storage.read(key: 'serverIp');
    String? username = await _storage.read(key: 'username');
    String? password = await _storage.read(key: 'password');
    String? database = await _storage.read(key: 'database');

     return User(
      serverIp: serverIp ?? '',
      username: username ?? '',
      password: password ?? '',
      database: database ?? '',
    );
  }

  // Method for debugging
  @override
  String toString() {
    return 'User(serverIp: $serverIp, username: $username, password: $password, database: $database)';
  }
}
