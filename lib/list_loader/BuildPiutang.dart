import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/b_tree_class.dart';
import 'package:test1/beans/user.dart';
import '../popups/views/piutang_view.dart';

//constructor
class Buildpiutang extends StatefulWidget {
  const Buildpiutang({super.key});

  @override
  _BuildPiutangState createState() => _BuildPiutangState();
}

//state untuk piutang
class _BuildPiutangState extends State<Buildpiutang> {
  //inisialisasi fungsi search
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredReceivables = [];
  final BTree _receivableBTree = BTree(3); // Degree of the tree

  //fetch transaksi yang memiliki piutang = true
  Future<void> fetchReceivables() async {
    User? user = await User.getUserCredentials();

    if (user == null) {
      throw Exception('No user data found');
    }

    final serverIp = user.serverIp;

    //post identitas database untuk meminta data / fetching
    final response = await http.post(
      Uri.parse('http://$serverIp:3000/receivables'),
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

    //jika fetch sukses
    if (response.statusCode == 200) {
      final receivables = json.decode(response.body)['receivables'];
      setState(() {
        _filteredReceivables = receivables;//kondisi jika tidak ada filter

        //pass semua list piutang ke b tree untuk di filter
        for (var receivable in receivables) {
          final lowerCaseName = receivable['nama_customer'].toLowerCase();
          _receivableBTree.insert(lowerCaseName, receivable);
        }
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  //fungsi untuk memanggil fungsi search b tree
  void _searchReceivable(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final matchedTransactions = _receivableBTree.searchBySubstring(lowerCaseQuery);
    setState(() {
      _filteredReceivables = matchedTransactions.toSet().toList();
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
                ? const Center(child: Text('No products available'))
                : ListView.builder(
                    itemCount: _filteredReceivables.length,
                    itemBuilder: (context, index) {
                      final receivable = _filteredReceivables[index];
                      return PiutangView(
                        id: receivable['id_transaksi'],
                        name: receivable['nama_customer'],
                        totalHarga: receivable['total_harga'].toString(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
