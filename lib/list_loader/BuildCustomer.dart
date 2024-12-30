import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/b_tree_class.dart';
import 'package:test1/beans/user.dart';
import '../popups/views/customer_view.dart';

//constructor
class Buildcustomer extends StatefulWidget {
  const Buildcustomer({super.key});

  @override
  _BuildCustomerState createState() => _BuildCustomerState();
}

class _BuildCustomerState extends State<Buildcustomer> {
  //inisialisasi fungsi search
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredCustomers = [];
  final BTree _customerBTree = BTree(3); 

  //fetch customer
  Future<void> fetchCustomer() async {
    User? user = await User.getUserCredentials();

    if (user == null) {
      throw Exception('No user data found');
    }

    final serverIp = user.serverIp;

    final response = await http.post(
      Uri.parse('http://$serverIp:3000/customers'),
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
      final customers = json.decode(response.body)['customers'];
      setState(() {
        _filteredCustomers = customers; //inisialisasi filter dengan data yang ada

        //memasukkan data yang terkena filter ke dalam b tree
        for (var customer in customers) {
          final lowerCaseName = customer['nama_customer'].toLowerCase();
          _customerBTree.insertIntoBtree(lowerCaseName, customer);
        }
      });
    } else {
      throw Exception('Failed to load customers');
    }
  }

  //fungsi untuk memanggil b tree ke dalam fungsi search dalam aplikasi
  void _searchCustomers(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final matchedCustomers = _customerBTree.searchBySubstring(lowerCaseQuery);
    setState(() {
      _filteredCustomers = matchedCustomers.toSet().toList();
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
                ? const Center(child: Text('No customer available'))
                : ListView.builder(
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = _filteredCustomers[index];
                      return CustomerView(
                        id: customer['id_customer'],
                        name: customer['nama_customer'],
                        noTelp: customer['no_telp_customer'].toString(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
