import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/storage/secure_storage.dart';

//constructor
class CustomerView extends StatefulWidget {
  final String name;
  final String noTelp;
  final int id;
  final void Function()? onTap;

  const CustomerView(
      {super.key,
      required this.name,
      required this.noTelp,
      required this.id,
      this.onTap});

  @override
  _CustomerViewState createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  bool _isHovered = false;
  bool _isPressed = false;

  //fetch data detail customer ke dalam popup
  Future<Map<String, dynamic>> fetchCustomerDetails(int customerId) async {
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

      //jika terkoneksi
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null || data['status'] != 'success') {
          throw Exception(
              'Failed to load customer details: ${data['message']}');
        }

        if (data['customers'] is Map<String, dynamic>) {
          return data['customers'];
        } else {
          throw Exception('Invalid data details format');
        }
      } else {
        throw Exception(
            'Failed to load customer details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching customer details: $e');
      throw Exception('Error fetching customer details');
    }
  }

  //fungsi untuk fetch data ke dalam popup
  Future<void> _showCustomerDetails(BuildContext context, customerId) async {
    try {
      final customerDetails = await fetchCustomerDetails(customerId);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(customerDetails['nama_customer'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('No Telp: ${customerDetails['no_telp_customer']}'),
                  Text('Email: ${customerDetails['email_customer']}'),
                  Text('NIK: ${customerDetails['nik']}'),
                  Text('Alamat : ${customerDetails['alamat']}')
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
            ],
          );
        },
      );
    } catch (e) {
      print('Error fetching customer details: $e');
    }
  }

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
              await _showCustomerDetails(context, widget.id);
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