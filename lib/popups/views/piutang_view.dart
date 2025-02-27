import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/storage/secure_storage.dart';
import 'package:intl/intl.dart';

//constructor
class PiutangView extends StatefulWidget {
  final String name;
  final String totalHarga;
  final int id;
  final void Function()? onTap;

  const PiutangView(
      {super.key,
      required this.name,
      required this.totalHarga,
      required this.id,
      this.onTap});

  @override
  _PiutangViewState createState() => _PiutangViewState();
}

class _PiutangViewState extends State<PiutangView> {
  bool _isHovered = false;
  bool _isPressed = false;

  //fetch detail transaksi
  Future<Map<String, dynamic>> fetchReceivableDetails(int transactionId) async {
    try {
      final db = await StorageService.getDatabaseIdentity();
      final password = await StorageService.getPassword();

      final response = await http.post(
        Uri.parse('http://${db['serverIp']}:3000/distributors'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'server_ip': db['serverIp'],
          'server_username': db['serverUsername'],
          'server_password': password,
          'server_database': db['serverDatabase'],
        }),
      );
      
      //jika fetch sukses
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null || data['status'] != 'success') {
          throw Exception('Failed to load receivable details: ${data['message']}');
        }

        if (data['transactions'] is Map<String, dynamic>) {
          return data['transactions'];
        } else {
          throw Exception('Invalid receivable details format');
        }
      } else {
        throw Exception(
            'Failed to load receivable details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching receivable details: $e');
      throw Exception('Error fetching receivable details');
    }
  }

  //fungsi untuk memunculkan detail piutang ke dalam popup
  Future<void> _showReceivableDetails(BuildContext context, int receivableId) async {
    try {
      final productDetails = await fetchReceivableDetails(receivableId);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Transaksi ${productDetails['id_transaksi']}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Tanggal: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(productDetails['tanggal_transaksi']))}'),
                  Text('Customer: ${productDetails['nama_customer']}'),
                  Text('No Telp: ${productDetails['no_telp_customer']}'),
                  Text('Email: ${productDetails['email_customer']}'),
                  Text('Total Harga: ${productDetails['total_harga']}'),
                  Text(
                      'Piutang: ${productDetails['piutang'] ? "Ya" : "Tidak"}'),
                  const SizedBox(height: 10),
                  const Text('Items:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...productDetails['items'].map<Widget>((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '${item['nama_barang']} - Qty: ${item['quantity']} - Subtotal: ${item['subtotal']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Kembali'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Edit'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hapus'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hubungi Customer'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error fetching receivable details: $e');
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
              await _showReceivableDetails(context, widget.id);
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
                  widget.totalHarga,
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
