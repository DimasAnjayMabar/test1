import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:test1/beans/user.dart';

class Buildpiutang extends StatelessWidget {
  const Buildpiutang({super.key});

  // Fetch products from the backend API using IP from the user object
  Future<List<dynamic>> fetchProducts() async {
    User? user = await User.getUserCredentials();

    if (user == null) {
      throw Exception('No user data found');
    }

    final serverIp = user.serverIp;

    final response = await http.post(
      Uri.parse('http://$serverIp:3000/transactions'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'servername': serverIp,
        'username': user.username,
        'password': user.password,
        'database': user.database,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['products'];
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: FutureBuilder<List<dynamic>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          final products = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: products.map((product) {
                // Ensure product['id_barang'] is an integer and is passed correctly
                final transactionId = product['id_transaksi'];
                if (transactionId == null) {
                  print('Error: Product ID is null');
                  return const SizedBox.shrink(); // Skip this card if no valid ID
                }

                return ProductCard(
                  id: transactionId, // Pass the product ID correctly
                  name: product['nama_customer'],
                  price: product['total_harga'].toString(),
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for FAB
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final int id;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.id,
  });

  // Function to fetch the product details by product ID
  Future<Map<String, dynamic>> fetchProductDetails(int transactionId) async {
    try {
      final user = await User.getUserCredentials(); // Retrieve saved user credentials
      if (user == null) {
        throw Exception('User data is null');
      }
      final serverIp = user.serverIp;

      final response = await http.post(
        Uri.parse('http://$serverIp:3000/transaction-details'), // Endpoint for product details
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'servername': serverIp,
          'username': user.username,
          'password': user.password,
          'database': user.database,
          'transaction_id': transactionId, // Send the product ID
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null || data['status'] != 'success') {
          throw Exception('Failed to load product details: ${data['message']}');
        }

        // Ensure that 'products' is an object (not a list)
        if (data['transaction'] is Map<String, dynamic>) {
          return data['transaction']; // Return the product details map
        } else {
          throw Exception('Invalid product details format');
        }
      } else {
        throw Exception('Failed to load product details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product details: $e');
      throw Exception('Error fetching product details');
    }
  }


  // Function to show the product details in a dialog
  Future<void> _showProductDetails(BuildContext context) async {
    try {
      final productDetails = await fetchProductDetails(id);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Transaksi ${productDetails['id_transaksi']}', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Tanggal: ${productDetails['tanggal_transaksi']}'),
                  Text('Customer: ${productDetails['nama_customer']}'),
                  Text('No Telp: ${productDetails['no_telp_customer']}'),
                  Text('Email: ${productDetails['email_customer']}'),
                  Text('Grand Total: ${productDetails['total_harga']}'),
                  Text('Receivable: ${productDetails['piutang'] ? "Yes" : "No"}'),
                  const SizedBox(height: 10),
                  const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
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
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Edit'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Kontak Customer'),
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
    return GestureDetector(
      onTap: () async {
        await _showProductDetails(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: double.infinity,
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              price,
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
    );
  }
}
