import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Admin {
  String username_admin;
  String password_admin;
  int id_admin; // Changed to int

  Admin({
    required this.username_admin,
    required this.password_admin,
    required this.id_admin,
  });

  // Save the admin credentials securely
  static const _storage = FlutterSecureStorage();

  // Save admin credentials to secure storage
  static Future<void> saveAdminCredentials(Admin admin) async {
    await _storage.write(key: 'username_admin', value: admin.username_admin);
    await _storage.write(key: 'password_admin', value: admin.password_admin);
    await _storage.write(key: 'id_admin', value: admin.id_admin.toString()); // Store as string
  }

  // Retrieve admin credentials from secure storage
  static Future<Admin?> getAdminCredentials() async {
    try {
      String? usernameAdmin = await _storage.read(key: 'username_admin');
      String? passwordAdmin = await _storage.read(key: 'password_admin');
      String? idAdminStr = await _storage.read(key: 'id_admin');

      if (usernameAdmin == null ||
          passwordAdmin == null ||
          idAdminStr == null) {
        return null; // Return null if any key is missing
      }

      int? idAdmin = int.tryParse(idAdminStr);
      if (idAdmin == null) {
        throw Exception('Invalid ID format'); // Handle invalid ID format
      }

      return Admin(
        username_admin: usernameAdmin,
        password_admin: passwordAdmin,
        id_admin: idAdmin,
      );
    } catch (e) {
      print('Error retrieving admin credentials: $e');
      return null;
    }
  }

  // Method for debugging
  @override
  String toString() {
    return 'Admin(username_admin: $username_admin, password_admin: $password_admin, id_admin: $id_admin)';
  }
}
