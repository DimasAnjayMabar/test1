import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/storage/secure_storage.dart';
import 'package:test1/beans/storage/temp_id_storage.dart';
import 'package:test1/popups/edit/edit_distributor.dart';
import 'package:test1/popups/verify/verify_admin.dart';
import 'package:test1/popups/verify/verify_pin.dart';

//constructor
class DistributorDetails extends StatefulWidget {
  final String name;
  final String noTelp;
  final int id;
  final void Function()? onTap;

  const DistributorDetails(
      {super.key,
      required this.name,
      required this.noTelp,
      required this.id,
      this.onTap});

  @override
  State<DistributorDetails> createState() => _DistributorDetailsState();
}

class _DistributorDetailsState extends State<DistributorDetails> {
  bool _isPressed = false;
  bool _isHovered = false;

  //fetch detail distributor ke dalam popup
  Future<Map<String, dynamic>> fetchDistributorDetails(int distributorId) async {
    try {
      final db = await StorageService.getDatabaseIdentity();
      final password = await StorageService.getPassword();

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
          'distributor_id': widget.id
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

  Future<void> _deleteDistributor(int distributorId) async {
    try {
      final dbIdentity = await StorageService.getDatabaseIdentity();
      final dbPassword = await StorageService.getPassword();

      // Request HTTP untuk menghapus distributor
      final response = await http.post(
        Uri.parse('http://${dbIdentity['serverIp']}:3000/delete-distributor'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'server_ip': dbIdentity['serverIp'],
          'server_username': dbIdentity['serverUsername'],
          'server_password': dbPassword,
          'server_database': dbIdentity['serverDatabase'],
          'distributor_id': distributorId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Distributor berhasil dihapus')),
            );
            Navigator.of(context).pop(); // Tutup dialog distributor
          }
        } else {
          throw Exception('Gagal menghapus distributor: ${data['message']}');
        }
      } else {
        throw Exception('Gagal menghapus distributor: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String getSafeString(String? value) {
    return (value == null || value.isEmpty) ? 'Tidak ada' : value;
  }

  //memasukkan hasil fetch ke dalam popup
  Future<void> _showDistributorDetails(BuildContext context, distributorId) async {
    try {
      final distributorDetails = await fetchDistributorDetails(distributorId);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(distributorDetails['distributor_name'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('No Telp: ${getSafeString(distributorDetails['distributor_phone_number'])}'),
                  const SizedBox(height: 5.0),
                  Text('Email: ${getSafeString(distributorDetails['distributor_email'])}'),
                  const SizedBox(height: 5.0),
                  Text('Ecommerce: ${getSafeString(distributorDetails['distributor_ecommerce_link'])}'),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Kembali'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black
                ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () async {
                  final bool pinVerified = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return VerifyPin(
                        onPinVerified: () {
                          Navigator.of(dialogContext).pop(true); // Kembalikan nilai true jika PIN berhasil diverifikasi
                        },
                      );
                    },
                  );

                  // Jika PIN berhasil diverifikasi, buka dialog EditDistributor
                  if (pinVerified == true) {
                    int distributorId = widget.id;

                    await TemporaryStorageId.saveIdTemporary(TemporaryStorageId(id: distributorId));

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const EditDistributor();
                      },
                    );
                  } else {
                    // Jika PIN tidak diverifikasi, Anda bisa menampilkan pesan atau tidak melakukan apa-apa
                    print("PIN verification failed or canceled.");
                  }
                },
                child: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return VerifyPin(
                        onPinVerified: () => _deleteDistributor(widget.id),
                      );
                    },
                  );
                },
                child: const Text('Hapus'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error fetching distributor details: $e');
    }
  }

  //fungsi untuk gesture detection agar kartu bisa di tekan
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _isPressed = true; // Trigger press state
          });
        },
        onTapUp: (_) {
          setState(() {
            _isPressed = false; // Release press state
          });
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false; // Cancel the press state
          });
        },
        onTap: widget.onTap ??
            () async {
              setState(() {
                _isPressed = true;
              });
              await _showDistributorDetails(context, widget.id);
              setState(() {
                _isPressed = false;
              });
            },
        child: AnimatedContainer(
          duration: const Duration(
              milliseconds: 200), // Duration for smooth color transition
          margin: const EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  spreadRadius: 1,
                  blurRadius: 8,
                ),
            ],
          ),
          child: Transform.scale(
            scale: _isPressed
                ? 0.95
                : 1.0, // Apply smooth scaling effect when pressed
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.noTelp,
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to get background color based on states (smooth transition)
  Color _getBackgroundColor() {
    if (_isPressed) {
      return Colors.orange; // Color when pressed
    } else if (_isHovered) {
      return Colors.orange.withOpacity(0.7); // Color when hovered
    }
    return Colors.grey[900]!; // Default color when not pressed or hovered
  }
} 