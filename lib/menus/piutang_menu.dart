import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/algorithm/b_tree/b_tree_class.dart';
import 'package:test1/beans/storage/secure_storage.dart';
import '../popups/views/piutang_view.dart';

//constructor
class PiutangMenu extends StatefulWidget {
  const PiutangMenu({super.key});

  @override
  State<PiutangMenu> createState() => _PiutangMenuState();
}

//state untuk piutang
class _PiutangMenuState extends State<PiutangMenu> {
  //inisialisasi fungsi search
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredReceivables = [];
  final BTree _receivableBTree = BTree(3); // Degree of the tree

  //fetch transaksi yang memiliki piutang = true
  Future<void> fetchReceivables() async {
    try {
      final db = await StorageService.getDatabaseIdentity();
      final password = await StorageService.getPassword();

      final response = await http.post(
        Uri.parse('http://${db['serverIp']}:3000/receivables'),
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
        final receivables = json.decode(response.body)['receivables'] ?? [];
        setState(() {
          _filteredReceivables = receivables;//kondisi jika tidak ada filter

          //pass semua list piutang ke b tree untuk di filter
          for (var receivable in receivables) {
            final lowerCaseName = (receivable['nama_customer'] ?? '').toLowerCase();
            if (lowerCaseName.isNotEmpty) {
              _receivableBTree.insertIntoBtree(lowerCaseName, receivable);
            }
          }
        });
      } else {
        throw Exception('Failed to load receivables');
      }
    } catch (e) {
      debugPrint('Error fetching receivables: $e');
      setState(() {
        _filteredReceivables = [];
      });
    }
  }

  //fungsi untuk memanggil fungsi search b tree
  void _searchReceivable(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final matchedTransactions = _receivableBTree.searchBySubstring(lowerCaseQuery);
    setState(() {
      _filteredReceivables = matchedTransactions?.toSet().toList() ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    fetchReceivables();
  }

//css atau ui
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
              onChanged: _searchReceivable,
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
            child: _filteredReceivables.isEmpty
                ? const Center(
                    child: Text(
                      'No receivables available',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredReceivables.length,
                    itemBuilder: (context, index) {
                      final receivable = _filteredReceivables[index];
                      return PiutangView(
                        id: receivable['id_transaksi'] ?? 'Unknown ID',
                        name: receivable['nama_customer'] ?? 'Unknown Customer',
                        totalHarga: 'Rp ${receivable['total_harga'] ?? 'N/A'}',
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
