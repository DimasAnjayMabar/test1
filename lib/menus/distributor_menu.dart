import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/algorithm/b_tree/b_tree_class.dart';
import 'package:test1/beans/storage/secure_storage.dart';
import 'package:test1/popups/add/add_distributor.dart';
import '../popups/views/distributor_details.dart';

//constructor
class DistributorMenu extends StatefulWidget {
  const DistributorMenu({super.key});

  @override
  State<DistributorMenu> createState() => _DistributorMenuState();
}

class _DistributorMenuState extends State<DistributorMenu> {
  //inisialisasi fungsi search
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredDistributors = [];
  final BTree _distributorBTree = BTree(3);
  bool _isRefreshing = false;


  //fetch data distributor 
  Future<void> fetchDistributors() async {
    try {
      final db = await StorageService.getDatabaseIdentity();
      final password = await StorageService.getPassword();

      final response = await http.post(
        Uri.parse('http://${db['serverIp']}:3000/distributors'),
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

      //jika terkoneksi
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final distributors = body['distributors'] ?? [];
        setState(() {
          _filteredDistributors = distributors;

          for (var distributor in distributors) {
            final lowerCaseName = (distributor['distributor_name'] ?? '').toLowerCase();
            if (lowerCaseName.isNotEmpty) {
              _distributorBTree.insertIntoBtree(lowerCaseName, distributor);
            }
          }
        });
      } else {
        throw Exception('Failed to load distributors');
      }
    } catch (e) {
      debugPrint('Error fetching distributors: $e');
      setState(() {
        _filteredDistributors = [];
      });
    }
  }

  //fungsi untuk memanggil b tree ke dalam fungsi search
  void _searchDistributor(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final matchedProducts = _distributorBTree.searchBySubstring(lowerCaseQuery);
    setState(() {
      _filteredDistributors = matchedProducts?.toSet().toList() ?? [];
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
            child: Row(
              children: [
                Expanded(
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
                IconButton(
                  icon: _isRefreshing
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _isRefreshing
                      ? null
                      : () async {
                          setState(() {
                            _isRefreshing = true; // Mulai loading
                          });
                          await fetchDistributors(); // Memuat ulang data distributor
                          setState(() {
                            _isRefreshing = false; // Selesai loading
                          });
                        },
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (_isRefreshing) return; // Hindari duplikasi proses refresh
                setState(() {
                  _isRefreshing = true; // Mulai loading
                });
                await fetchDistributors(); // Memuat ulang data distributor
                setState(() {
                  _isRefreshing = false; // Selesai loading
                });
              },
              child: _filteredDistributors.isEmpty
                  ? const Center(
                      child: Text(
                        'No distributor available',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      itemCount: _filteredDistributors.length,
                      itemBuilder: (context, index) {
                        final distributor = _filteredDistributors[index];
                        return DistributorDetails(
                          id: distributor['distributor_id'] ?? 'Unknown ID',
                          name: distributor['distributor_name'] ?? 'Unknown Name',
                          noTelp: distributor['distributor_phone_number']?.toString() ?? 'Unknown Phone',
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddDistributor(); // This will show as a dialog instead of a new page
            },
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
