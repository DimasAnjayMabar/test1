import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/storage/admin.dart';
import 'package:test1/beans/storage/secure_storage.dart';
import 'package:test1/menus/settings_page.dart';
import 'package:flutter/services.dart';
import 'package:test1/popups/verify/settings/verify_pin_change.dart';

class EditPin extends StatefulWidget {
  const EditPin({super.key});

  @override
  _EditPinState createState() => _EditPinState();
}

class _EditPinState extends State<EditPin> {
  // Inisialisasi
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode =
      FocusNode(); // FocusNode untuk menangkap event keyboard

  String? usernameAdmin;
  String? passwordAdmin;
  int? idAdmin;
  String? newPin; // Variabel untuk menyimpan PIN baru

  Future<void> _EditPinForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final db = await StorageService.getDatabaseIdentity();
        final password = await StorageService.getPassword();
        final admin = await Admin.getAdminCredentials();

        // Tampilkan indikator loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final response = await http.post(
          Uri.parse('http://${db['serverIp']}:3000/edit-pin'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'server_ip': db['serverIp'],
            'server_username': db['serverUsername'],
            'server_password': password,
            'server_database': db['serverDatabase'],
            'admin_id': admin?.id_admin ?? '',
            'new_pin': newPin
          }),
        );

        Navigator.pop(context); // Tutup indikator loading

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pin edited successfully!')),
          );
          Navigator.of(context).pop(true);
        } else {
          throw Exception('Failed to edit pin: ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop(false); // Menutup dialog saat Esc ditekan
          } else if (event.logicalKey == LogicalKeyboardKey.enter) {
            _EditPinForm(); // Memanggil _EditPinForm saat Enter ditekan
          }
        }
      },
      child: AlertDialog(
        title: const Text(
          'Edit Pin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'New PIN'),
                  obscureText: true, // Input untuk PIN disembunyikan
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan PIN baru';
                    }
                    if (value.length != 6) {
                      return 'PIN harus terdiri dari 6 digit';
                    }
                    return null;
                  },
                  onSaved: (value) => newPin = value, // Simpan PIN baru
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false), // Kembali
            child: const Text('Kembali'),
            style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black
                ),
          ),
          ElevatedButton(
            onPressed: () {
              VerifyPinChange.showExitPopup(
                context,
                () {
                  // Panggil fungsi _EditPinForm
                  _EditPinForm();
                },
              );
            },
            child: const Text('Simpan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
