import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/user.dart';
import 'package:test1/list_loader/SettingsPage.dart';

class VerifyAdmin extends StatefulWidget {
  const VerifyAdmin({super.key});

  @override
  _VerifyAdminState createState() => _VerifyAdminState();
}

class _VerifyAdminState extends State<VerifyAdmin> {
  // Inisialisasi
  final _formKey = GlobalKey<FormState>();

  String? username_admin;
  String? password_admin;
  String? selectedAdminId;

  // Fungsi untuk submit data produk baru
  Future<void> _loginForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final user = await User.getUserCredentials();
        if (user == null) throw Exception('User not found');

        // Show loading indicator while the request is being processed
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final response = await http.post(
          Uri.parse('http://${user.serverIp}:3000/verify-admin'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'servername': user.serverIp,
            'username': user.username,
            'password': user.password,
            'database': user.database,
            'username_admin': username_admin,
            'password_admin': password_admin,
          }),
        );

        Navigator.pop(context); // Close the loading indicator dialog

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin verified successfully!')),
          );
          // Navigasi ke Settingspage setelah verifikasi berhasil
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Settingspage()),
            (Route<dynamic> route) => false, // Hapus semua rute sebelumnya
          );
        } else {
          throw Exception('Failed to verify admin: ${response.body}');
        }
      } catch (e) {
        Navigator.pop(context); // Close the loading indicator on error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // UI for the form
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
                onSaved: (value) => username_admin = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                keyboardType: TextInputType.text,
                obscureText: true, // Hide the input for password
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan password yang benar';
                  }
                  return null;
                },
                onSaved: (value) => password_admin = value,
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(false), // Return false if cancel
          child: const Text('Kembali'),
        ),
        ElevatedButton(
          onPressed: _loginForm, // Submit form for verification
          child: const Text('Verifikasi'),
        ),
      ],
    );
  }
}
