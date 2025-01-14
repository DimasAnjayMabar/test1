import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/storage/admin.dart';
import 'package:test1/beans/storage/secure_storage.dart';
import 'package:test1/menus/settings_page.dart';
import 'package:flutter/services.dart';

class VerifyAdmin extends StatefulWidget {
  const VerifyAdmin({super.key});

  @override
  _VerifyAdminState createState() => _VerifyAdminState();
}

class _VerifyAdminState extends State<VerifyAdmin> {
  // Inisialisasi
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode(); // FocusNode untuk menangkap event keyboard

  String? usernameAdmin;
  String? passwordAdmin;
  int? idAdmin;

  Future<void> _loginForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final db = await StorageService.getDatabaseIdentity();
        final password = await StorageService.getPassword();

        // Tampilkan indikator loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final response = await http.post(
        Uri.parse('http://${db['serverIp']}:3000/verify-admin'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'server_ip': db['serverIp'],
          'server_username': db['serverUsername'],
          'server_password': password,
          'server_database': db['serverDatabase'],
          'admin_username': usernameAdmin,
          'admin_password': passwordAdmin
        }),
      );

        Navigator.pop(context); // Tutup indikator loading

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['status'] == 'success') {
            final adminData = data['admin'];

            // Pastikan id_admin adalah int sebelum konversi
            if (adminData['admin_id'] is int) {
              idAdmin = adminData['admin_id']; // Ambil id_admin dari response
            } else {
              throw Exception('id is not an integer');
            }

            // Simpan kredensial admin menggunakan fungsi yang sudah ada
            await Admin.saveAdminCredentials(Admin(
              username_admin: usernameAdmin!,
              password_admin: passwordAdmin!,
              id_admin: idAdmin!, // Menyimpan id_admin sebagai int
            ));

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Admin verified successfully!')),
            );

            // Navigasi ke SettingsPage
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
              (Route<dynamic> route) => false,
            );
          } else {
            throw Exception('Verification failed: ${data['message']}');
          }
        } else {
          throw Exception('Failed to verify admin: ${response.body}');
        }
      } catch (e) {
        Navigator.pop(context); // Tutup indikator loading saat error
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
            _loginForm(); // Memanggil loginForm saat Enter ditekan
          }
        }
      },
      child: AlertDialog(
        title: const Text(
          'Verifikasi Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan username';
                    }
                    return null;
                  },
                  onSaved: (value) => usernameAdmin = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true, // Input untuk password disembunyikan
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan password yang benar';
                    }
                    return null;
                  },
                  onSaved: (value) => passwordAdmin = value,
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
            onPressed: _loginForm, // Verifikasi form
            child: const Text('Verifikasi'),
          ),
        ],
      ),
    );
  }
}
