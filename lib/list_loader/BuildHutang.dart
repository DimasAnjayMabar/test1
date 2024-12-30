import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/b_tree_class.dart';
import 'package:test1/beans/user.dart';
import '../popups/views/hutang_view.dart';

//constructor
class Buildhutang extends StatefulWidget {
  const Buildhutang({super.key});

  @override
  _BuildhutangState createState() => _BuildhutangState();
}

//create state
class _BuildhutangState extends State<Buildhutang> {
  //inisialisasi fungsi search
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredDebts = [];
  final BTree _debtBTree = BTree(3);

  //fetch produk yang berisi hutang = true
  Future<void> fetchDebts() async {
    User? user = await User.getUserCredentials();

    if (user == null) {
      throw Exception('No user data found');
    }

    final serverIp = user.serverIp;

    final response = await http.post(
      Uri.parse('http://$serverIp:3000/debts'),
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
      final debts = json.decode(response.body)['debts'];
      setState(() {
        _filteredDebts = debts; //kondisi inisial dimana filter tidak diaktifkan

        //memasukkan produk yang terkena filter ke dalam b tree
        for (var product in debts) {
          final lowerCaseName = product['nama_barang'].toLowerCase();
          _debtBTree.insertIntoBtree(lowerCaseName, product);
        }
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  //fungsi untuk memanggil search b tree ke dalam aplikasi
  void _searchDebt(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final matchedProducts =
        _debtBTree.searchBySubstring(lowerCaseQuery); // Use substring search
    setState(() {
      _filteredDebts =
          matchedProducts.toSet().toList(); // Remove duplicates if any
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
                ? const Center(child: Text('No products available'))
                : ListView.builder(
                    itemCount: _filteredDebts.length,
                    itemBuilder: (context, index) {
                      final debt = _filteredDebts[index];
                      return HutangView(
                        id: debt['id_barang'],
                        name: debt['nama_barang'],
                        price: debt['harga_jual'].toString(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
