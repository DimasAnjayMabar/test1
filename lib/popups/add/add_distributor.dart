import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/user.dart';

class AddProductPopup extends StatefulWidget {
  const AddProductPopup({super.key});

  @override
  _AddProductPopupState createState() => _AddProductPopupState();
}

class _AddProductPopupState extends State<AddProductPopup> {
  //inisialisasi
  final _formKey = GlobalKey<FormState>();

  String? namaDistributor;
  String? noTelpDistributor;
  String? emailDistributor;
  String? linkEcommerce;

  //fungsi untuk submit data produk baru
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final user = await User.getUserCredentials();
        if (user == null) throw Exception('User not found');

        final response = await http.post(
          Uri.parse('http://${user.serverIp}:3000/new-distributor'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'servername': user.serverIp,
            'username': user.username,
            'password': user.password,
            'database': user.database,
            'nama_distributor': namaDistributor,
            'no_telp_distributor': noTelpDistributor,
            'email_distributor': emailDistributor,
            'link_ecommerce': linkEcommerce,
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
                  if (value == null || value.isEmpty) {
                    return 'Masukkan email distributor';
                  }
                  return null;
                },
                onSaved: (value) => emailDistributor = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Link Ecommerce'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan link ecommerce';
                  }
                  return null;
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
        ),
        ElevatedButton(
          //submit produk baru
          onPressed: _submitForm,
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}
