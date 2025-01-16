import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/algorithm/b_tree/b_tree_class.dart';
import 'package:test1/beans/storage/secure_storage.dart';
import 'package:test1/popups/add/add_barang.dart';
import 'package:test1/popups/views/product_view.dart';

class GudangMenu extends StatefulWidget {
  const GudangMenu({super.key});

  @override
  State<GudangMenu> createState() => _GudangMenuState();
}

class _GudangMenuState extends State<GudangMenu> {
  // Inisialisasi
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredProducts = [];
  final BTree _productBTree = BTree(3); // degree B tree

  // Fetch produk ke dalam list
  Future<void> fetchProducts() async {
    try {
      final db = await StorageService.getDatabaseIdentity();
      final password = await StorageService.getPassword();

      final response = await http.post(
        Uri.parse('http://${db['serverIp']}:3000/products'),
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

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final products = body['products'] ?? [];
        setState(() {
          // Menginisialisasi state dengan filter produk kosong
          _filteredProducts = products;

          // Memasukkan produk dalam B tree
          for (var product in products) {
            final lowerCaseName = (product['nama_barang'] ?? '').toLowerCase();
            if (lowerCaseName.isNotEmpty) {
              _productBTree.insertIntoBtree(lowerCaseName, product);
            }
          }
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      setState(() {
        _filteredProducts = [];
      });
    }
  }

  // Penggunaan B tree untuk fungsi pencarian
  void _searchProducts(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final matchedProducts = _productBTree.searchBySubstring(lowerCaseQuery);
    setState(() {
      _filteredProducts = matchedProducts?.toSet().toList() ?? [];
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
                        name: product['nama_barang'] ?? 'Unknown Product',
                        price: 'Rp ${product['harga_jual'] ?? 'N/A'}',
                        id: product['id_barang'] ?? 'Unknown ID',
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
              return Dialog(
                child: SizedBox(
                  width: 400, // Tentukan lebar yang diinginkan
                  height: 600, // Tentukan tinggi yang diinginkan
                  child: AddBarang(),
                ),
              );
            },
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
