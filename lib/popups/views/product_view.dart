import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/user.dart';
import 'package:intl/intl.dart';

class ProductView extends StatefulWidget {
  final String name;
  final String price;
  final int id;
  final void Function()? onTap;

  const ProductView({
    super.key,
    required this.name,
    required this.price,
    required this.id,
    this.onTap,
  });

  @override
  _ProductViewState createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  bool _isHovered = false; // Untuk mengontrol efek hover
  bool _isPressed = false;

  Future<Map<String, dynamic>> fetchProductDetails(int productId) async {
    try {
      final user = await User.getUserCredentials();
      if (user == null) {
        throw Exception('User data is null');
      }
      final serverIp = user.serverIp;

      final response = await http.post(
        Uri.parse('http://$serverIp:3000/product-details'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'servername': serverIp,
          'username': user.username,
          'password': user.password,
          'database': user.database,
          'product_id': productId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null || data['status'] != 'success') {
          throw Exception('Failed to load product details: ${data['message']}');
        }

        if (data['products'] is Map<String, dynamic>) {
          return data['products'];
        } else {
          throw Exception('Invalid product details format');
        }
      } else {
        throw Exception(
            'Failed to load product details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product details: $e');
      throw Exception('Error fetching product details');
    }
  }

  // Menampilkan detail produk
  Future<void> _showProductDetails(BuildContext context, int productId) async {
    try {
      final productDetails = await fetchProductDetails(productId);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              productDetails['nama_barang'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Harga Jual: ${productDetails['harga_jual']}'),
                  Text('Harga Beli: ${productDetails['harga_beli']}'),
                  Text('Stok: ${productDetails['stok']}'),
                  Text(
                      'Tanggal: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(productDetails['tanggal_masuk']))}'),
                  Text('Barcode: ${productDetails['barcode']}'),
                  Text('Hutang: ${productDetails['hutang'] ? "Ya" : "Tidak"}'),
                  const SizedBox(height: 10),
                  const Text(
                    'Distributor:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Nama: ${productDetails['nama_distributor']}'),
                  Text('No Telp: ${productDetails['no_telp_distributor']}'),
                  Text('Email: ${productDetails['email_distributor']}'),
                  Text('Ecommerce: ${productDetails['link_ecommerce']}'),
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
                child: const Text('Buat Barcode'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hubungi Distributor'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error fetching product details: $e');
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
        onTap: widget.onTap ?? () async {
          setState(() {
            _isPressed = true;
          });
          await _showProductDetails(context, widget.id);
          setState(() {
            _isPressed = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), // Duration for smooth color transition
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
            scale: _isPressed ? 0.95 : 1.0, // Apply smooth scaling effect when pressed
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
                  widget.price,
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
