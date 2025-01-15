import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TemporaryStorageId {
  int id; // Changed to int

  TemporaryStorageId({
    required this.id,
  });

  // Save the admin credentials securely
  static const _storage = FlutterSecureStorage();

  // Save admin credentials to secure storage
  static Future<void> saveIdTemporary(TemporaryStorageId temporaryStorage) async {
    await _storage.write(key: 'id', value: temporaryStorage.id.toString()); // Store as string
  }

  // Retrieve admin credentials from secure storage
  static Future<TemporaryStorageId?> getIdTemporary() async {
    try {
      String? idStr = await _storage.read(key: 'id');

      if (idStr == null) {
        return null; // Return null if any key is missing
      }

      int? id = int.tryParse(idStr);
      if (id == null) {
        throw Exception('Invalid ID format'); // Handle invalid ID format
      }

      return TemporaryStorageId(
        id: id,
      );
    } catch (e) {
      print('Error retrieving admin credentials: $e');
      return null;
    }
  }

  static Future<void> deleteAll() async{
    await _storage.delete(key: 'id');
  }

  // Method for debugging
  @override
  String toString() {
    return 'TemporaryStorage(id: $id)';
  }
}
