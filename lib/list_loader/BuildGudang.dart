import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/b_tree_class.dart';
import 'package:test1/beans/user.dart';
import 'package:test1/popups/add/add_barang.dart';
import 'package:test1/popups/views/product_view.dart';

class Buildgudang extends StatefulWidget {
  const Buildgudang({super.key});

  @override
  _BuildgudangState createState() => _BuildgudangState();
}

class _BuildgudangState extends State<Buildgudang> {
  // Inisialisasi
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredProducts = [];
  //rui c14230277
  final BTree _productBTree = BTree(3); // degree B tree

  // Fetch produk ke dalam list
  Future<void> fetchProducts() async {
    User? user = await User.getUserCredentials();
    if (user == null) {
      throw Exception('No user data found');
    }

    final serverIp = user.serverIp;

    final response = await http.post(
      Uri.parse('http://$serverIp:3000/products'),
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

    //greg c14230127
    if (response.statusCode == 200) {
      final products = json.decode(response.body)['products'];
      setState(() {
        // Menginisialisasi state dengan filter produk kosong
        _filteredProducts = products;

        // Memasukkan produk dalam B tree
        for (var product in products) {
          final lowerCaseName = product['nama_barang'].toLowerCase();
          _productBTree.insertIntoBtree(lowerCaseName, product);
        }
      });
    } else {
      throw Exception('Failed to load products');
    }
  }
  
  //rui c14230277
  // Penggunaan B tree untuk fungsi pencarian
  void _searchProducts(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final matchedProducts = _productBTree.searchBySubstring(lowerCaseQuery);
    setState(() {
      // Set state filtered product dengan matched product
      _filteredProducts = matchedProducts.toSet().toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              //rui c14230277
              onChanged: _searchProducts,
              decoration: InputDecoration(
                labelText: 'Cari Produk',
                filled: true,
                fillColor: Colors.grey[700],
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // Menampilkan kartu produk
          //joey c14230256
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      'No products available',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return ProductView(
                        name: product['nama_barang'],
                        price: 'Rp ${product['harga_jual']}',
                        id: product['id_barang'],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddProductPopup();
            },
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
