import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/storage/admin.dart';
import 'package:test1/beans/storage/secure_storage.dart';
import 'package:test1/beans/storage/temp_id_storage.dart';
import 'package:test1/beans/storage/temp_pin_storage.dart';
import 'package:test1/menus/settings_page.dart';
import 'package:flutter/services.dart';
import 'package:test1/popups/verify/distributor/verify_distributor_change.dart';

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
  String? alasanPerubahan;
  Map<String, dynamic>? distributorData;
  bool isLoading = true;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _linkEcommerceController =
      TextEditingController();
  final TextEditingController _alasanPerubahanController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDistributorDetails();
  }

  Future<Map<String, dynamic>> fetchDistributorDetails(
      int distributorId) async {
    try {
      final db = await StorageService.getDatabaseIdentity();
      final password = await StorageService.getPassword();
      final temporaryStorage = await TemporaryStorageId.getIdTemporary();
      final distributorId = temporaryStorage?.id;

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
          'distributor_id': distributorId
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
            return data['distributor']
                [0]; // Return the first distributor if needed
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

  Future<void> _loadDistributorDetails() async {
    final temporaryStorage = await TemporaryStorageId.getIdTemporary();
    final distributorId = temporaryStorage?.id;

    try {
      final distributorDetails = await fetchDistributorDetails(
          distributorId!); // Gunakan ID distributor yang sesuai
      setState(() {
        _namaController.text = distributorDetails['distributor_name'] ?? '';
        _noTelpController.text =
            distributorDetails['distributor_phone_number'] ?? '';
        _emailController.text = distributorDetails['distributor_email'] ?? '';
        _linkEcommerceController.text =
            distributorDetails['distributor_ecommerce_link'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching distributor details: $e')),
      );
    }
  }

  Future<void> _EditDistributorForm() async {
    if (_formKey.currentState!.validate()) {
      // Simpan nilai dari kontroler
      final namaDistributor = _namaController.text;
      final noTelpDistributor = _noTelpController.text;
      final emailDistributor = _emailController.text;
      final linkEcommerce = _linkEcommerceController.text;

      try {
        final db = await StorageService.getDatabaseIdentity();
        final password = await StorageService.getPassword();
        final distributorId = await TemporaryStorageId.getIdTemporary();
        final adminPin = (await TemporaryStoragePin.getPinTemporary())?.pin;

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
            'distributor_ecommerce_link': linkEcommerce,
            'distributor_change_detail': _alasanPerubahanController.text,
            'admin_pin': adminPin,
          }),
        );

        Navigator.pop(context); // Tutup indikator loading

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Distributor edited successfully!')),
          );
          Navigator.of(context).pop(true);
        } else {
          final errorMessage = 'Failed to edit distributor: ${response.body}';
          print(errorMessage); // Menampilkan error di konsol (console log)
          throw Exception(errorMessage); // Akan ditangkap oleh blok catch
        }
      } catch (e) {
        // Menampilkan error di konsol dan di SnackBar
        print('Error: $e'); // Menampilkan error di konsol (console log)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')), // Menampilkan error di SnackBar
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : RawKeyboardListener(
            focusNode: _focusNode,
            onKey: (RawKeyEvent event) {
              if (event is RawKeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.escape) {
                  Navigator.of(context).pop(false);
                } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                  _EditDistributorForm();
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Data Distributor:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16, // Bisa disesuaikan
                        ),
                      ),
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(labelText: 'Nama'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan nama distributor';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _noTelpController,
                        decoration:
                            const InputDecoration(labelText: 'Nomor Telepon'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan no telp distributor';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final emailRegex =
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Masukkan email yang valid';
                            }
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _linkEcommerceController,
                        decoration:
                            const InputDecoration(labelText: 'Link Ecommerce'),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final urlRegex = RegExp(
                                r'^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-]*)*\/?$');
                            if (!urlRegex.hasMatch(value)) {
                              return 'Masukkan link yang valid';
                            }
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20), // Adding space between the fields
                      const Text(
                        'Alasan Perubahan: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16, // Bisa disesuaikan
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _alasanPerubahanController,
                        decoration: const InputDecoration(
                          labelText: 'Masukkan alasan',
                          border: OutlineInputBorder(), // Adds a box-like border
                        ),
                        maxLines: 4,  // Allows multiple lines for longer text input
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan alasan perubahan';
                          }
                          return null;
                        },
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
                      foregroundColor: Colors.black),
                ),
                ElevatedButton(
                  onPressed: () {
                    VerifyDistributorChange.showExitPopup(
                      context,
                      () {
                        // Panggil fungsi _EditPinForm
                        _EditDistributorForm();
                      },
                    );
                  },
                  child: const Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          );
  }
}
