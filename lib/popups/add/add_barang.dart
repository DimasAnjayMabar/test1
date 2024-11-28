import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/user.dart';

class AddProductPopup extends StatefulWidget {
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
  DateTime tanggalMasuk = DateTime.now();
  bool hutang = false;

  // Function to calculate the selling price based on profit percentage
  void _calculateHargaJual() {
    if (hargaBeli != null) {
      setState(() {
        hargaJual = hargaBeli! + (hargaBeli! * (profitPercentage / 100)).round();
      });
    }
  }

  // Function to send the data to the server
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final user = await User.getUserCredentials(); // Assuming user info is stored
        if (user == null) throw Exception('User not found');

        final response = await http.post(
          Uri.parse('http://${user.serverIp}:3000/add-barang'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'nama_barang': namaBarang,
            'harga_beli': hargaBeli,
            'harga_jual': hargaJual,
            'tanggal_masuk': tanggalMasuk.toIso8601String(),
            'stok': stok,
            'hutang': hutang,
          }),
        );

        if (response.statusCode == 200) {
          Navigator.of(context).pop(true); // Close the dialog and return success
        } else {
          throw Exception('Failed to add product');
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
    return AlertDialog(
      title: const Text('Add New Product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nama Barang'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter product name';
                  return null;
                },
                onSaved: (value) => namaBarang = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Harga Beli'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) return 'Enter a valid price';
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
                decoration: const InputDecoration(labelText: 'Profit Percentage (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) return 'Enter a valid percentage';
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
                decoration: InputDecoration(
                  labelText: 'Harga Jual (Calculated)',
                  hintText: hargaJual?.toString() ?? '0',
                ),
                readOnly: true,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) return 'Enter stock quantity';
                  return null;
                },
                onSaved: (value) => stok = int.parse(value!),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tanggal Masuk:'),
                  TextButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: tanggalMasuk,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          tanggalMasuk = selectedDate;
                        });
                      }
                    },
                    child: Text(
                      '${tanggalMasuk.toLocal()}'.split(' ')[0],
                    ),
                  ),
                ],
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
