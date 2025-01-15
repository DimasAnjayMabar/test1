import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TemporaryStoragePin {
  String pin;

  TemporaryStoragePin({
    required this.pin,
  });

  // Save the admin credentials securely
  static const _storage = FlutterSecureStorage();

  // Save admin credentials to secure storage
  static Future<void> savePinTemporary(TemporaryStoragePin temporaryStorage) async {
    await _storage.write(
        key: 'pin', value: temporaryStorage.pin.toString()); // Store as string
  }

  // Retrieve admin credentials from secure storage
  static Future<TemporaryStoragePin?> getPinTemporary() async {
    try {
      String? pin = await _storage.read(key: 'pin');

      return TemporaryStoragePin(
        pin: pin!,
      );
    } catch (e) {
      print('Error retrieving admin credentials: $e');
      return null;
    }
  }

  static Future<void> deleteAll() async {
    await _storage.delete(key: 'id');
  }

  // Method for debugging
  @override
  String toString() {
    return 'TemporaryStorage(pin: $pin)';
  }
}
