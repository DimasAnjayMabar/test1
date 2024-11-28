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
  final _formKey = GlobalKey<FormState>();

  String? namaBarang;
  int? hargaBeli;
  int? hargaJual;
  int? stok;
  double profitPercentage = 0;
  bool hutang = false;
  String? selectedDistributorId;
  List<Map<String, String>> distributors = []; // List to store distributor data

  // Function to calculate the selling price based on profit percentage
  void _calculateHargaJual() {
    if (hargaBeli != null) {
      setState(() {
        hargaJual =
            hargaBeli! + (hargaBeli! * (profitPercentage / 100)).round();
      });
    }
  }

  // Fetch distributors from the database
  Future<void> _fetchDistributors() async {
    try {
      final user = await User.getUserCredentials();
      if (user == null) throw Exception('User not found');

      final response = await http.post(
        Uri.parse('http://${user.serverIp}:3000/distributors'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'servername': user.serverIp,
          'username': user.username,
          'password': user.password,
          'database': user.database,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          distributors = List<Map<String, String>>.from(
            data['distributors'].map((distributor) {
              // Ensure that the 'id_distributor' and 'nama_distributor' are cast to strings
              return {
                'id_distributor': distributor['id_distributor'].toString(),
                'nama_distributor': distributor['nama_distributor'].toString(),
              };
            }),
          );
        });
      } else {
        throw Exception('Failed to fetch distributors');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching distributors: $e')),
      );
    }
  }


  // Function to send the data to the server
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final user = await User.getUserCredentials();
        if (user == null) throw Exception('User not found');

        final response = await http.post(
          Uri.parse('http://${user.serverIp}:3000/new-product'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'servername': user.serverIp,
            'username': user.username,
            'password': user.password,
            'database': user.database,
            'nama_barang': namaBarang,
            'harga_beli': hargaBeli,
            'harga_jual': hargaJual,
            'stok': stok,
            'hutang': hutang,
            'id_distributor': int.tryParse(selectedDistributorId ?? ''), // Convert to int
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully!')),
          );
          Navigator.of(context)
              .pop(true); // Close the dialog and return success
        } else {
          throw Exception('Failed to add product: ${response.body}');
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
    _fetchDistributors(); // Fetch distributors when the form loads
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Tambah Barang Baru',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nama Barang'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Masukkan nama produk';
                  return null;
                },
                onSaved: (value) => namaBarang = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Harga Beli'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null)
                    return 'Masukkan harga dengan benar';
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    hargaBeli = int.tryParse(value);
                    _calculateHargaJual();
                  });
                },
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Persen Profit (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null)
                    return 'Masukkan hanya angka biasa (sudah dalam bentuk persen)';
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    profitPercentage = double.tryParse(value) ?? 0;
                    _calculateHargaJual();
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null)
                    return 'Masukkan stok barang';
                  return null;
                },
                onSaved: (value) => stok = int.parse(value!),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Distributor'),
                items: distributors
                    .map((distributor) {
                      // Ensure 'id_distributor' is treated as a string
                      return DropdownMenuItem<String>(
                        value: distributor['id_distributor']?.toString(), // Convert to String
                        child: Text(distributor['nama_distributor']!),
                      );
                    })
                    .toList(),
                onChanged: (value) {
                  // Ensure value is a String
                  setState(() => selectedDistributorId = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Pilih distributor';
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Hutang:'),
                  Switch(
                    value: hutang,
                    onChanged: (value) {
                      setState(() {
                        hutang = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // Cancel action
          child: const Text('Kembali'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}