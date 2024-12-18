import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/user.dart';
import 'package:intl/intl.dart';

class TransaksiView extends StatefulWidget {
  final String name;
  final String totalHarga;
  final int id;
  final void Function()? onTap;

  const TransaksiView({
    super.key,
    required this.name,
    required this.totalHarga,
    required this.id,
    this.onTap,
  });

  @override
  _TransaksiViewState createState() => _TransaksiViewState();
}

class _TransaksiViewState extends State<TransaksiView> {
  bool _isHovered = false;
  bool _isPressed = false;

  // Function to fetch the product details by product ID
  Future<Map<String, dynamic>> fetchTransactionDetails(
      int transactionId) async {
    try {
      final user = await User.getUserCredentials();
      if (user == null) {
        throw Exception('User data is null');
      }
      final serverIp = user.serverIp;

      final response = await http.post(
        Uri.parse('http://$serverIp:3000/transaction-details'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'servername': serverIp,
          'username': user.username,
          'password': user.password,
          'database': user.database,
          'transaction_id': transactionId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null || data['status'] != 'success') {
          throw Exception('Failed to load transaction details: ${data['message']}');
        }

        if (data['transactions'] is Map<String, dynamic>) {
          return data['transactions'];
        } else {
          throw Exception('Invalid transaction details format');
        }
      } else {
        throw Exception(
            'Failed to load transaction details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching transaction details: $e');
      throw Exception('Error fetching transaction details');
    }
  }

  // Function to show the product details in a dialog
  Future<void> _showTransactionDetails(
      BuildContext context, int transactionId) async {
    try {
      final productDetails = await fetchTransactionDetails(transactionId);

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
            ],
          );
        },
      );
    } catch (e) {
      print('Error fetching transaction details: $e');
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
              await _showTransactionDetails(context, widget.id);
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
