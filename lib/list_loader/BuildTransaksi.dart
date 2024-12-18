import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/b_tree_class.dart';
import 'package:test1/beans/user.dart';
import 'package:test1/popups/add/add_transaksi.dart';
import '../popups/views/transaksi_view.dart';

class Buildtransaksi extends StatefulWidget {
  const Buildtransaksi({super.key});

  @override
  _BuildTransaksiState createState() => _BuildTransaksiState();
}

class _BuildTransaksiState extends State<Buildtransaksi> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredTransactions = [];
  final BTree _transactionBTree = BTree(3); // Degree of the tree

  // Fetch products from the backend API and insert them into the B-Tree
  Future<void> fetchTransactions() async {
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
      final transactions = json.decode(response.body)['transactions'];
      setState(() {
        _filteredTransactions = transactions; // Initially show all products

        // Insert products into the B-Tree
        for (var transaction in transactions) {
          final lowerCaseName = transaction['nama_customer'].toLowerCase(); // Convert product name to lowercase
          _transactionBTree.insert(lowerCaseName, transaction);
        }
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Search products based on user input using the B-Tree
  void _searchTransactions(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final matchedTransactions = _transactionBTree.searchBySubstring(lowerCaseQuery); // Use substring search
    setState(() {
      _filteredTransactions = matchedTransactions.toSet().toList(); // Remove duplicates if any
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTransactions();
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
              onChanged: _searchTransactions,
              decoration: InputDecoration(
                labelText: 'Cari Transaksi',
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
            child: _filteredTransactions.isEmpty
                ? const Center(child: Text('No products available'))
                : ListView.builder(
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      return TransaksiView(
                        id: transaction['id_transaksi'],
                        name: transaction['nama_customer'],
                        totalHarga: 'Rp ${transaction['total_harga']}',
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
              return const AddTransaksiPopup(); // This will show as a dialog instead of a new page
            },
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
