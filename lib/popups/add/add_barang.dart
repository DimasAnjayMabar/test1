import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/storage/secure_storage.dart';

// Helper untuk responsivitas
class ResponsiveHelper {
  static double getFontSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Mengubah ukuran font berdasarkan lebar layar
    if (screenWidth <= 992) {
      return 14.0; // Font lebih kecil untuk layar kecil
    } else {
      return 18.0; // Font lebih besar untuk layar besar
    }
  }

  static EdgeInsets getPadding(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Mengubah padding berdasarkan lebar layar
    if (screenWidth <= 992) {
      return EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 10.0); // Padding kecil
    } else {
      return EdgeInsets.symmetric(
          horizontal: 32.0, vertical: 20.0); // Padding lebih besar
    }
  }
}

class TableRowData {
  String name;
  String buyPrice;
  String percentProfit;
  String stock;
  String category;

  TableRowData({
    this.name = '',
    this.buyPrice = '',
    this.percentProfit = '',
    this.stock = '',
    this.category = '',
  });
}

class AddBarang extends StatefulWidget {
  @override
  State<AddBarang> createState() => _AddBarangState();
}

class _AddBarangState extends State<AddBarang> {
   List<String> distributorList = [];
  List<String> categoryList = [];
  String selectedDistributor = '';
  DateTime selectedDate = DateTime.now();
  double fontSize = 16.0;
  List<TableRowData> rowDataList = [];
  
  final ScrollController verticalScrollController = ScrollController();
  final ScrollController horizontalScrollController = ScrollController();

  @override
  void dispose() {
    verticalScrollController.dispose();
    horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchDistributorDropdown();
    fetchCategoryDropdown();
    addRow(); // Tambahkan row default saat pertama kali
  }

  Future<void> fetchDistributorDropdown() async {
    try {
      // Ambil data konfigurasi database dan password
      final db = await StorageService.getDatabaseIdentity();
      final password = await StorageService.getPassword();

      // Kirim request POST ke endpoint /distributors
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

      // Periksa status respons
      if (response.statusCode == 200) {
        final body = json.decode(response.body); // Decode JSON respons

        // Ambil daftar distributor dari JSON
        final distributors = body['distributors'] ?? [];
        setState(() {
          distributorList = List<String>.from(
            distributors.map((distributor) => distributor['distributor_name']),
          );
        });
      } else {
        throw Exception('Failed to load distributors: ${response.statusCode}');
      }
    } catch (e) {
      // Tangkap dan tampilkan error
      print('Error fetching distributors: $e');
    }
  }

  Future<void> fetchCategoryDropdown() async {
    try {
      final db = await StorageService.getDatabaseIdentity();
      final password = await StorageService.getPassword();

      final response = await http.post(
        Uri.parse('http://${db['serverIp']}:3000/categories'),
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
        final categories = body['categories'] ?? [];
        setState(() {
          categoryList = List<String>.from(
            categories.map((category) => category['category_name']),
          );
        });
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void addRow() {
    setState(() {
      rowDataList.add(TableRowData());
    });
  }

  void removeRow(int index) {
    setState(() {
      rowDataList.removeAt(index);
    });
  }

  void selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PRODUK BARU",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    "TANGGAL: ${selectedDate.day} - ${selectedDate.month} - ${selectedDate.year}",
                    style: TextStyle(color: Colors.black, fontSize: fontSize),
                  ),
                  IconButton(
                    onPressed: () => selectDate(context),
                    icon: Icon(Icons.calendar_today, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    "DISTRIBUTOR: ",
                    style: TextStyle(color: Colors.black, fontSize: fontSize),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedDistributor.isEmpty
                          ? null
                          : selectedDistributor,
                      hint: Text("Select Distributor",
                          style: TextStyle(fontSize: fontSize)),
                      dropdownColor: Colors.white,
                      items: distributorList.map((distributor) {
                        return DropdownMenuItem<String>(
                          value: distributor,
                          child: Text(distributor,
                              style: TextStyle(
                                  fontSize: fontSize, color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDistributor = value ?? '';
                        });
                      },
                    ),
                  ),
                  Spacer(),
                ],
              ),
              Expanded(
                child: Scrollbar(
                  controller: horizontalScrollController,
                  thumbVisibility: true, // Agar scrollbar terlihat
                  child: SingleChildScrollView(
                    controller: horizontalScrollController,
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Scrollbar(
                      controller: verticalScrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: verticalScrollController,
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        child: Table(
                          border: TableBorder.all(color: Colors.black),
                          columnWidths: {
                            0: IntrinsicColumnWidth(),
                            1: IntrinsicColumnWidth(),
                            2: IntrinsicColumnWidth(),
                            3: IntrinsicColumnWidth(),
                            4: IntrinsicColumnWidth(),
                            5: IntrinsicColumnWidth(),
                          },
                          children: [
                            TableRow(
                              children: [
                                Text("NAME"),
                                Text("BUY PRICE"),
                                Text("PERCENT PROFIT"),
                                Text("STOCK"),
                                Text("CATEGORY"),
                                Text("REMOVE"),
                              ],
                            ),
                            ...rowDataList.asMap().entries.map((entry) {
                              int index = entry.key;
                              TableRowData data = entry.value;
                              return TableRow(
                                children: [
                                  TextField(
                                    decoration:
                                        InputDecoration(hintText: "Name"),
                                    onChanged: (value) => setState(() {
                                      data.name = value;
                                    }),
                                  ),
                                  TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        hintText: "Buy Price"),
                                    onChanged: (value) => setState(() {
                                      data.buyPrice = value;
                                    }),
                                  ),
                                  TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        hintText: "Percent Profit"),
                                    onChanged: (value) => setState(() {
                                      data.percentProfit = value;
                                    }),
                                  ),
                                  TextField(
                                    keyboardType: TextInputType.number,
                                    decoration:
                                        InputDecoration(hintText: "Stock"),
                                    onChanged: (value) => setState(() {
                                      data.stock = value;
                                    }),
                                  ),
                                  DropdownButton<String>(
                                    isExpanded: true,
                                    value: data.category.isEmpty
                                        ? null
                                        : data.category,
                                    hint: Text("Select Category"),
                                    items: categoryList.map((category) {
                                      return DropdownMenuItem<String>(
                                        value: category,
                                        child: Text(category),
                                      );
                                    }).toList(),
                                    onChanged: (value) => setState(() {
                                      data.category = value ?? '';
                                    }),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: () => setState(() {
                                      removeRow(index);
                                    }),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: addRow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Warna tombol
                      shape:
                          CircleBorder(), // Membuat tombol berbentuk lingkaran
                    ),
                    child: Icon(Icons.add,
                        color: Colors.white), // Ikon dan warnanya
                  ),
                ],
              ),
              SizedBox(
                  height: 10), // Add some space between buttons and grand total
              Row(
                children: [
                  Text(
                    "GRAND TOTAL: Rp. 0",
                    style: TextStyle(color: Colors.black, fontSize: fontSize),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Kembali menutup alert dialog
                    },
                    child: Text("Kembali"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text("Simpan"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
