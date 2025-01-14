import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/algorithm/b_tree/b_tree_class.dart';
import 'package:test1/beans/storage/secure_storage.dart';
import '../popups/views/customer_view.dart';

//constructor
class CustomerMenu extends StatefulWidget {
  const CustomerMenu({super.key});

  @override
  State<CustomerMenu> createState() => _CustomerMenuState();
}

class _CustomerMenuState extends State<CustomerMenu> {
  //inisialisasi fungsi search
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredCustomers = [];
  final BTree _customerBTree = BTree(3);

  //fetch customer
  Future<void> fetchCustomer() async {
    try {
      final db = await StorageService.getDatabaseIdentity();
      final password = await StorageService.getPassword();

      final response = await http.post(
        Uri.parse('http://${db['serverIp']}:3000/customers'),
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
        final customers = body['customers'] ?? [];

        setState(() {
          _filteredCustomers = customers;

          for (var customer in customers) {
            final lowerCaseName =
                (customer['nama_customer'] ?? '').toLowerCase();
            if (lowerCaseName.isNotEmpty) {
              _customerBTree.insertIntoBtree(lowerCaseName, customer);
            }
          }
        });
      } else {
        throw Exception('Failed to load customers');
      }
    } catch (e) {
      debugPrint('Error fetching customers: $e');
      setState(() {
        _filteredCustomers = [];
      });
    }
  }

  //fungsi untuk memanggil b tree ke dalam fungsi search dalam aplikasi
  void _searchCustomers(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final matchedCustomers = _customerBTree.searchBySubstring(lowerCaseQuery);
    setState(() {
      _filteredCustomers = matchedCustomers?.toSet().toList() ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCustomer();
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
              onChanged: _searchCustomers,
              decoration: InputDecoration(
                labelText: 'Cari Customer',
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
            child: _filteredCustomers.isEmpty
                ? const Center(
                    child: Text('No customer available',
                        style: TextStyle(color: Colors.white)))
                : ListView.builder(
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = _filteredCustomers[index];
                      return CustomerView(
                        id: customer['id_customer'] ?? 'Unknown ID',
                        name: customer['nama_customer'] ?? 'Unknown Name',
                        noTelp: customer['no_telp_customer']?.toString() ??
                            'Unknown Phone',
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
