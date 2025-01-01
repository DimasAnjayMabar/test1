import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/admin.dart';
import 'package:test1/beans/user.dart';
import 'package:test1/list_loader/SettingsPage.dart';
import 'package:flutter/services.dart';

class EditPin extends StatefulWidget {
  const EditPin({super.key});

  @override
  _EditPinState createState() => _EditPinState();
}

class _EditPinState extends State<EditPin> {
  // Inisialisasi
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode(); // FocusNode untuk menangkap event keyboard

  String? usernameAdmin;
  String? passwordAdmin;
  int? idAdmin;
  String? newPin;  // Variabel untuk menyimpan PIN baru

  Future<void> _EditPinForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final user = await User.getUserCredentials();
        if (user == null) throw Exception('User not found');
        final admin = await Admin.getAdminCredentials();
        if (admin == null) throw Exception('Admin not found');

        // Tampilkan indikator loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final response = await http.post(
          Uri.parse('http://${user.serverIp}:3000/edit-pin'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'servername': user.serverIp,
            'username': user.username,
            'password': user.password,
            'database': user.database,
            'id_admin': admin.id_admin,
            'new_pin': newPin, // Kirimkan PIN baru
          }),
        );

        Navigator.pop(context); // Tutup indikator loading

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pin edited successfully!')),
          );
          Navigator.of(context)
              .pop(true); 
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
          ),
          ElevatedButton(
            onPressed: _EditPinForm, // Verifikasi form
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
