import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

// Secure Storage untuk password
const _secureStorage = FlutterSecureStorage();

// Hive untuk data non-sensitif
final _hiveBox = Hive.box('database_identity');

class StorageService {
  // Simpan identitas database
  static Future<void> saveDatabaseIdentity({
    required String serverIp,
    required String serverUsername,
    required String serverDatabase,
  }) async {
    await _hiveBox.put('serverIp', serverIp);
    await _hiveBox.put('serverUsername', serverUsername);
    await _hiveBox.put('serverDatabase', serverDatabase);
  }

  // Simpan password secara aman
  static Future<void> savePassword(String password) async {
    await _secureStorage.write(key: 'serverPassword', value: password);
  }

  // Ambil identitas database
  static Map<String, String> getDatabaseIdentity() {
    return {
      'serverIp': _hiveBox.get('serverIp', defaultValue: ''),
      'serverUsername': _hiveBox.get('serverUsername', defaultValue: ''),
      'serverDatabase': _hiveBox.get('serverDatabase', defaultValue: ''),
    };
  }

  // Ambil password
  static Future<String?> getPassword() async {
    return await _secureStorage.read(key: 'serverPassword');
  }

  // Hapus password (untuk logout)
  static Future<void> deletePassword() async {
    await _secureStorage.delete(key: 'serverPassword');
  }

  // Hapus semua data
  static Future<void> clearAllData() async {
    await _hiveBox.clear();
    await _secureStorage.deleteAll();
  }
}
