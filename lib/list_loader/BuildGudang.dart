import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:test1/beans/user.dart';

class Buildgudang extends StatelessWidget {
  const Buildgudang({super.key});

  // Fetch products from the backend API using IP from the user object
  Future<List<dynamic>> fetchProducts() async {
    // Ensure we have a user in the list, and use the first user as the default
    if (userList.isEmpty) {
      throw Exception('No user data found');
    }

    final serverIp = userList[0].serverIp; // Get server IP from the first user

    // Make an HTTP GET request to fetch products using the server IP
    final response = await http.get(Uri.parse('http://$serverIp:3000/products'));

    if (response.statusCode == 200) {
      // Parsing JSON hanya jika berhasil
      return json.decode(response.body)['products'];
    } else {
      // Cetak status code dan body untuk debugging
      print('Failed to load products: ${response.statusCode}');
      print('Response body: ${response.body}');
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
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products available'));
          }

          // If products are successfully fetched, display them
          final products = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            physics: BouncingScrollPhysics(),
            child: Column(
              children: products.map((product) {
                return ProductCard(
                  name: product['nama_barang'],
                  price: product['harga_jual'],
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
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final String name;
  final String price;

  const ProductCard({super.key, required this.name, required this.price});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _handleTap() {
    setState(() {
      _isPressed = true;
    });

    // Briefly reset the press state to create a tap effect
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isPressed = false;
        });
      }
    });

    // Action when card is clicked
    print('Card tapped!');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: MouseRegion(
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
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _isPressed
                ? Colors.yellow[700]
                : (_isHovered ? Colors.orange[700] : Colors.grey[900]),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? Colors.orange[300]! : Colors.black26,
                blurRadius: 6,
                spreadRadius: _isHovered ? 2 : 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.price,
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
