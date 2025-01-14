import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:test1/beans/storage/secure_storage.dart';

class VerifyPin extends StatefulWidget {
  final VoidCallback onPinVerified;

  const VerifyPin({super.key, required this.onPinVerified});

  @override
  State<VerifyPin> createState() => _VerifyPinState();
}

class _VerifyPinState extends State<VerifyPin> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();

  String? adminPin;

  Future<void> _verifyPin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final dbIdentity = await StorageService.getDatabaseIdentity();
        final dbPassword = await StorageService.getPassword();

        // Tampilkan indikator loading
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return const Center(child: CircularProgressIndicator());
            },
          );
        }

        final response = await http.post(
          Uri.parse('http://${dbIdentity['serverIp']}:3000/verify-pin'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'server_ip': dbIdentity['serverIp'],
            'server_username': dbIdentity['serverUsername'],
            'server_password': dbPassword,
            'server_database': dbIdentity['serverDatabase'],
            'admin_pin': adminPin,
          }),
        );

        if (mounted) Navigator.pop(context); // Tutup indikator loading

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            // Tampilkan pesan sukses
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verifikasi sukses')),
              );
            }

            // Jalankan callback
            widget.onPinVerified();

            // Tutup dialog VerifyPin
            if (mounted) Navigator.of(context).pop(true);
          } else {
            throw Exception(data['message'] ?? 'Verifikasi gagal');
          }
        } else {
          throw Exception('Gagal untuk verifikasi pin: ${response.body}');
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Tutup indikator loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
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
            _verifyPin(); // Memanggil loginForm saat Enter ditekan
          }
        }
      },
      child: AlertDialog(
        title: const Text(
          'Verifikasi Pin',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Pin'),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan PIN';
                    } else if (value.length < 4 || value.length > 6) {
                      return 'PIN harus 4-6 digit';
                    }
                    return null;
                  },
                  onSaved: (value) => adminPin = value,
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: _verifyPin,
            child: const Text('Verifikasi'),
          ),
        ],
      ),
    );
  }
}
