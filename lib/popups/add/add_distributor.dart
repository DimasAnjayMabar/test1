import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/storage/secure_storage.dart';
import 'package:test1/menus/distributor_menu.dart';
import 'package:test1/popups/verify/distributor/verify_distributor_change.dart';
import 'package:test1/popups/verify/distributor/verify_distributor_create.dart';

class AddDistributor extends StatefulWidget {
  const AddDistributor({super.key});

  @override
  State<AddDistributor> createState() => _AddDistributorMenu();
}

class _AddDistributorMenu extends State<AddDistributor> {
  //inisialisasi
  final _formKey = GlobalKey<FormState>();

  String? namaDistributor;
  String? noTelpDistributor;
  String? emailDistributor;
  String? linkEcommerce;

  //fungsi untuk submit data produk baru
  Future<void> _createDistributor() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final db = await StorageService.getDatabaseIdentity();
        final password = await StorageService.getPassword();

        final response = await http.post(
          Uri.parse('http://${db['serverIp']}:3000/new-distributor'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'server_ip': db['serverIp'],
            'server_username': db['serverUsername'],
            'server_password': password,
            'server_database': db['serverDatabase'],
            'distributor_name': namaDistributor,
            'distributor_phone_number': noTelpDistributor,
            'distributor_email': emailDistributor,
            'distributor_ecommerce_link': linkEcommerce,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Distributor added successfully!')),
          );
          Navigator.of(context)
              .pop(true); 
        } else {
          throw Exception('Failed to add distributor: ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

//css atau ui
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Tambah Distributor Baru',
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
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Kembali'),
          style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black
                ),
        ),
        ElevatedButton(
                  onPressed: () {
                    VerifyDistributorCreate.showExitPopup(
                      context,
                      () {
                        // Panggil fungsi _EditPinForm
                        _createDistributor();
                      },
                    );
                  },
                  child: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                  ),
                ),
      ],
    );
  }
}
