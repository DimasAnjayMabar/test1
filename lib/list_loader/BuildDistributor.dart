import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/b_tree_class.dart';
import 'package:test1/beans/user.dart';
import 'package:test1/popups/add/add_distributor.dart';
import '../popups/views/distributor_view.dart';

//constructor
class Builddistributor extends StatefulWidget {
  const Builddistributor({super.key});

  @override
  _BuildDistributorState createState() => _BuildDistributorState();
}

class _BuildDistributorState extends State<Builddistributor> {
  //inisialisasi fungsi search
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredDistributors = [];
  final BTree _distributorBTree = BTree(3);

  //fetch data distributor 
  Future<void> fetchDistributors() async {
    User? user = await User.getUserCredentials();

    if (user == null) {
      throw Exception('No user data found');
    }

    final serverIp = user.serverIp;

    final response = await http.post(
      Uri.parse('http://$serverIp:3000/distributors'),
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

    //jika terkoneksi
    if (response.statusCode == 200) {
      final distributors = json.decode(response.body)['distributors'];
      setState(() {
        _filteredDistributors = distributors;

        for (var distributor in distributors) {
          final lowerCaseName = distributor['nama_distributor'].toLowerCase();
          _distributorBTree.insertIntoBtree(lowerCaseName, distributor);
        }
      });
    } else {
      throw Exception('Failed to load distributors');
    }
  }

  //fungsi untuk memanggil b tree ke dalam fungsi search
  void _searchDistributor(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final matchedProducts = _distributorBTree.searchBySubstring(lowerCaseQuery);
    setState(() {
      _filteredDistributors = matchedProducts.toSet().toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDistributors();
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
              onChanged: _searchDistributor,
              decoration: InputDecoration(
                labelText: 'Cari Distributor',
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
            child: _filteredDistributors.isEmpty
                ? const Center(child: Text('No distributor available'))
                : ListView.builder(
                    itemCount: _filteredDistributors.length,
                    itemBuilder: (context, index) {
                      final distributor = _filteredDistributors[index];
                      return DistributorView(
                        id: distributor['id_distributor'],
                        name: distributor['nama_distributor'],
                        noTelp: distributor['no_telp_distributor'].toString(),
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
              return const AddProductPopup(); // This will show as a dialog instead of a new page
            },
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
