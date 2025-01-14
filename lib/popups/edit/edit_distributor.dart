import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/storage/admin.dart';
import 'package:test1/beans/storage/secure_storage.dart';
import 'package:test1/beans/storage/temporary_storage.dart';
import 'package:test1/menus/settings_page.dart';
import 'package:flutter/services.dart';

class EditDistributor extends StatefulWidget {
  const EditDistributor({super.key});

  @override
  State<EditDistributor> createState() => _EditDistributorState();
}

class _EditDistributorState extends State<EditDistributor> {
  // Inisialisasi
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode =
      FocusNode(); // FocusNode untuk menangkap event keyboard
  String? namaDistributor;
  String? noTelpDistributor;
  String? emailDistributor;
  String? linkEcommerce;
  Map<String, dynamic>? distributorData;
  bool isLoading = true;


  Future<Map<String, dynamic>> fetchDistributorDetails(int distributorId) async {
    try {
      final db = await StorageService.getDatabaseIdentity();
      final password = await StorageService.getPassword();
      final distributorId = await TemporaryStorage.getIdTemporary();

      final response = await http.post(
        Uri.parse('http://${db['serverIp']}:3000/distributor-details'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'server_ip': db['serverIp'],
          'server_username': db['serverUsername'],
          'server_password': password,
          'server_database': db['serverDatabase'],
          'distributor_id': distributorId?.id ?? ''
        }),
      );

      //jika terkoneksi
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null || data['status'] != 'success') {
          throw Exception(
              'Failed to load distributor details: ${data['message']}');
        }

       if (data['distributor'] is List<dynamic>) {
          if (data['distributor'].isNotEmpty) {
            return data['distributor'][0]; // Return the first distributor if needed
          } else {
            throw Exception('Distributor slist is empty');
          }
        } else if (data['distributor'] is Map<String, dynamic>) {
          return data['distributor'];
        } else {
          throw Exception('Invalid data details format');
        }
      } else {
        throw Exception(
            'Failed to load distributors details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching distributor details: $e');
      throw Exception('Error fetching distributor details');
    }
  }

  Future<void> _EditDistributorForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final db = await StorageService.getDatabaseIdentity();
        final password = await StorageService.getPassword();
        final distributorId = await TemporaryStorage.getIdTemporary();

        // Tampilkan indikator loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final response = await http.post(
          Uri.parse('http://${db['serverIp']}:3000/edit-distributor'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'server_ip': db['serverIp'],
            'server_username': db['serverUsername'],
            'server_password': password,
            'server_database': db['serverDatabase'],
            'distributor_id': distributorId?.id ?? '',
            'distributor_name': namaDistributor,
            'distributor_phone_number': noTelpDistributor,
            'distributor_email': emailDistributor,
            'distributor_ecommerce_link': linkEcommerce
          }),
        );

        Navigator.pop(context); // Tutup indikator loading

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Distributor edited successfully!')),
          );
          Navigator.of(context).pop(true);
        } else {
          throw Exception('Failed to edit distributor: ${response.body}');
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
            _EditDistributorForm(); // Memanggil _EditPinForm saat Enter ditekan
          }
        }
      },
      child: AlertDialog(
        title: const Text(
          'Edit Distributor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan nama distributor';
                    }
                    return null;
                  },
                  onSaved: (value) => namaDistributor = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan no telp distributor';
                    }
                    return null;
                  },
                  onSaved: (value) => noTelpDistributor = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Masukkan email yang valid';
                      }
                    }
                    return null; // Tidak ada error jika kosong
                  },
                  onSaved: (value) => emailDistributor = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Link Ecommerce'),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final urlRegex = RegExp(r'^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-]*)*\/?$');
                      if (!urlRegex.hasMatch(value)) {
                        return 'Masukkan link yang valid';
                      }
                    }
                    return null; // Tidak ada error jika kosong
                  },
                  onSaved: (value) => linkEcommerce = value,
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
            onPressed: _EditDistributorForm, // Verifikasi form
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
