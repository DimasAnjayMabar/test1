import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/algorithm/b_tree/b_tree_class.dart';
import 'package:test1/beans/storage/secure_storage.dart';
import '../popups/views/hutang_view.dart';

//constructor
class HutangMenu extends StatefulWidget {
  const HutangMenu({super.key});

  @override
  State<HutangMenu> createState() => _HutangMenuState();
}

//create state
class _HutangMenuState extends State<HutangMenu> {
  //inisialisasi fungsi search
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredDebts = [];
  final BTree _debtBTree = BTree(3);

  //fetch produk yang berisi hutang = true
  Future<void> fetchDebts() async {
    try {
      final db = await StorageService.getDatabaseIdentity();
      final password = await StorageService.getPassword();

      final response = await http.post(
        Uri.parse('http://${db['serverIp']}:3000/debts'),
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
        final debts = json.decode(response.body)['debts'] ?? [];
        setState(() {
          _filteredDebts = debts;

          for (var product in debts) {
            final lowerCaseName = (product['nama_barang'] ?? '').toLowerCase();
            if (lowerCaseName.isNotEmpty) {
              _debtBTree.insertIntoBtree(lowerCaseName, product);
            }
          }
        });
      } else {
        throw Exception('Failed to load debts');
      }
    } catch (e) {
      debugPrint('Error fetching debts: $e');
      setState(() {
        _filteredDebts = [];
      });
    }
  }

  //fungsi untuk memanggil search b tree ke dalam aplikasi
  void _searchDebt(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final matchedProducts = _debtBTree.searchBySubstring(lowerCaseQuery);
    setState(() {
      _filteredDebts = matchedProducts?.toSet().toList() ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDebts();
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
              onChanged: _searchDebt,
              decoration: InputDecoration(
                labelText: 'Cari Hutang',
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
            child: _filteredDebts.isEmpty
                ? const Center(
                    child: Text(
                      'No debts available',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredDebts.length,
                    itemBuilder: (context, index) {
                      final debt = _filteredDebts[index];
                      return HutangView(
                        id: debt['id_barang'] ?? 'Unknown ID',
                        name: debt['nama_barang'] ?? 'Unknown Product',
                        price: 'Rp ${debt['harga_jual'] ?? 'N/A'}',
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
