import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/user.dart';

class AddTransaksiPopup extends StatefulWidget {
  const AddTransaksiPopup({super.key});

  @override
  _AddTransaksiPopupState createState() => _AddTransaksiPopupState();
}

class _AddTransaksiPopupState extends State<AddTransaksiPopup> {
  final _formKey = GlobalKey<FormState>();

  String? alamatCustomer;
  String? nikCustomer;
  String? emailCustomer;
  String? notelpCustomer;
  String? namaCustomer;
  String? namaBarang;
  int? hargaBeli;
  int? hargaJual;
  int? stok;
  double profitPercentage = 0;
  bool piutang = false;
  String? selectedProductId;
  List<Map<String, String>> products = []; // List to store distributor data

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
  Future<void> _fetchProducts() async {
    try {
      final user = await User.getUserCredentials();
      if (user == null) throw Exception('User not found');

      final response = await http.post(
        Uri.parse('http://${user.serverIp}:3000/new-transaction'),
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
          products = List<Map<String, String>>.from(
            data['products'].map((product) {
              // Ensure that the 'id_distributor' and 'nama_distributor' are cast to strings
              return {
                'id_barang': product['id_barang'].toString(),
                'nama_barang': product['nama_barang'].toString(),
              };
            }),
          );
        });
      } else {
        throw Exception('Failed to fetch products');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
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
            'piutang': piutang,
            'id_barang':
                int.tryParse(selectedProductId ?? ''), // Convert to int
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
    _fetchProducts(); // Fetch distributors when the form loads
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Tambah Transaksi Baru',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Daftar Transaksi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10), // Menambahkan jarak antara teks dan tombol
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Tambahkan logika untuk mencari barang
                    },
                    icon: const Icon(Icons.search), // Ikon pencarian
                    label: const Text('Cari Barang'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Tambahkan logika untuk scan barcode
                          },
                          icon: const Icon(Icons.qr_code_scanner), // Ikon scan barcode
                          label: const Text('Scan Barcode'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                        ),
                      ],
                  ),
                ],
              ),
              const SizedBox(height: 20), // Menambahkan jarak antara tombol dan elemen lainnya
              const Text('Customer:', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nama Customer'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan nama customer';
                  }
                  return null;
                },
                onSaved: (value) => namaCustomer = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'No Telp'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan nomor telepon';
                  }
                  return null;
                },
                onSaved: (value) => notelpCustomer = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan email';
                  }
                  return null;
                },
                onSaved: (value) => emailCustomer = value,
              ),
              if (piutang) ...[ // Hanya tampil jika piutang == true
                TextFormField(
                  decoration: const InputDecoration(labelText: 'NIK'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan NIK';
                    }
                    return null;
                  },
                  onSaved: (value) => nikCustomer = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Alamat'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan alamat';
                    }
                    return null;
                  },
                  onSaved: (value) => alamatCustomer = value,
                ),
              ],
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Piutang:'),
                  Switch(
                    value: piutang,
                    onChanged: (value) {
                      setState(() {
                        piutang = value;
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
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(false), // Cancel action,
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
