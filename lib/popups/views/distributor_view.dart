import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/user.dart';

//constructor
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

  //fetch detail distributor ke dalam popup
  Future<Map<String, dynamic>> fetchDistributorDetails(int distributorId) async {
    try {
      final user = await User.getUserCredentials();
      if (user == null) {
        throw Exception('User data is null');
      }
      final serverIp = user.serverIp;

      final response = await http.post(
        Uri.parse('http://$serverIp:3000/distributor-details'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'servername': serverIp,
          'username': user.username,
          'password': user.password,
          'database': user.database,
          'distributor_id': distributorId,
        }),
      );
      
      //jika terkoneksi
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null || data['status'] != 'success') {
          throw Exception('Failed to load distributor details: ${data['message']}');
        }

        if (data['distributors'] is Map<String, dynamic>) {
          return data['distributors'];
        } else {
          throw Exception('Invalid data details format');
        }
      } else {
        throw Exception('Failed to load distributors details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching distributor details: $e');
      throw Exception('Error fetching deistributor details');
    }
  }

  //memasukkan hasil fetch ke dalam popup
  Future<void> _showDistributorDetails(BuildContext context) async {
    try {
      final productDetails = await fetchDistributorDetails(id);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(productDetails['nama_distributor'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('No Telp: ${productDetails['no_telp_distributor']}'),
                  Text('Email: ${productDetails['email_distributor']}'),
                  Text('Ecommerce: ${productDetails['link_ecommerce']}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Kembali'),
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
                child: const Text('Hapus'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error fetching product details: $e');
    }
  }

//gesture detection agar kartu bisa ditekan
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _showDistributorDetails(context);
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
