import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/algorithm/b_tree/b_tree_class.dart';
import 'package:test1/beans/storage/secure_storage.dart';
import 'package:test1/popups/add/add_transaksi.dart';
import '../popups/views/transaksi_view.dart';

class TransaksiMenu extends StatefulWidget {
  const TransaksiMenu({super.key});

  @override
  State<TransaksiMenu> createState() => _TransaksiMenuState();
}

class _TransaksiMenuState extends State<TransaksiMenu> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredTransactions = [];
  final BTree _transactionBTree = BTree(3); // Degree of the tree

  // Fetch transactions from the backend API and insert them into the B-Tree
  Future<void> fetchTransactions() async {
    try {
      final db = await StorageService.getDatabaseIdentity();
      final password = await StorageService.getPassword();

      final response = await http.post(
        Uri.parse('http://${db['serverIp']}:3000/transactions'),
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
        final transactions = json.decode(response.body)['transactions'] ?? [];
        setState(() {
          _filteredTransactions = transactions; // Initially show all transactions

          // Insert transactions into the B-Tree
          for (var transaction in transactions) {
            final lowerCaseName = (transaction['nama_customer'] ?? '').toLowerCase();
            if (lowerCaseName.isNotEmpty) {
              _transactionBTree.insertIntoBtree(lowerCaseName, transaction);
            }
          }
        });
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      setState(() {
        _filteredTransactions = [];
      });
    }
  }

  // Search transactions based on user input using the B-Tree
  void _searchTransactions(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final matchedTransactions = _transactionBTree.searchBySubstring(lowerCaseQuery);
    setState(() {
      _filteredTransactions = matchedTransactions?.toSet().toList() ?? [];
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
                ? const Center(
                    child: Text(
                      'No transactions available',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      return TransaksiView(
                        id: transaction['id_transaksi'] ?? 'Unknown ID',
                        name: transaction['nama_customer'] ?? 'Unknown Customer',
                        totalHarga: 'Rp ${transaction['total_harga'] ?? 'N/A'}',
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
