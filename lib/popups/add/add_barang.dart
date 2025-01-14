import 'package:flutter/material.dart';

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

class AddBarang extends StatefulWidget {
  @override
  State<AddBarang> createState() => _AddBarangState();
}

class _AddBarangState extends State<AddBarang> {
  List<TableRow> rows = [];
  String selectedDistributor = '';
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    addRow(); // Tambahkan row default saat pertama kali
  }

  void addRow() {
    setState(() {
      rows.add(
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(decoration: InputDecoration(hintText: "Name")),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: "Buy Price"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: "Percent Profit"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: "Stock"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                isExpanded: true,
                value: null,
                dropdownColor: Colors.white,
                hint: Text("Category"),
                items: ['Category A', 'Category B', 'Category C']
                    .map((category) => DropdownMenuItem<String>(
                        value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("0"), // Placeholder untuk subtotal
            ),
          ],
        ),
      );
    });
  }

  void removeRow() {
    if (rows.isNotEmpty) {
      setState(() {
        rows.removeLast();
      });
    }
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
    double fontSize = ResponsiveHelper.getFontSize(context);

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
              "PRODUK BARU", // Title above the date
              style: TextStyle(
                  color: Colors.black,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
                height: 10), // Adds some space between the title and the date
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
                Text("DISTRIBUTOR: ",
                    style: TextStyle(color: Colors.black, fontSize: fontSize)),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value:
                      selectedDistributor.isEmpty ? null : selectedDistributor,
                  hint: Text("Select Distributor",
                      style: TextStyle(fontSize: fontSize)),
                  dropdownColor: Colors.white,
                  items: ['Distributor A', 'Distributor B', 'Distributor C']
                      .map((distributor) => DropdownMenuItem<String>(
                          value: distributor,
                          child: Text(distributor,
                              style: TextStyle(
                                  fontSize: fontSize, color: Colors.black))))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDistributor = value ?? '';
                    });
                  },
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal, // Menambahkan scroll horizontal
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context)
                          .size
                          .width), // Pastikan tabel memiliki lebar minimal
                  child: SingleChildScrollView(
                    scrollDirection:
                        Axis.vertical, // Scroll vertikal tetap ditambahkan
                    child: Table(
                      border: TableBorder.all(color: Colors.black),
                      columnWidths: {
                        0: IntrinsicColumnWidth(), // Kolom NAME menyesuaikan konten
                        1: IntrinsicColumnWidth(), // Kolom BUY PRICE menyesuaikan konten
                        2: IntrinsicColumnWidth(), // Kolom PERCENT PROFIT menyesuaikan konten
                        3: IntrinsicColumnWidth(), // Kolom STOCK menyesuaikan konten
                        4: IntrinsicColumnWidth(), // Kolom CATEGORY menyesuaikan konten
                        5: IntrinsicColumnWidth(), // Kolom SUBTOTAL menyesuaikan konten
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.white),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("NAME",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: fontSize)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("BUY PRICE",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: fontSize)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("PERCENT PROFIT",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: fontSize)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("STOCK",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: fontSize)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("CATEGORY",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: fontSize)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("SUBTOTAL",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: fontSize)),
                            ),
                          ],
                        ),
                        ...rows,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  onPressed: addRow,
                  icon: Icon(Icons.add, color: Colors.black),
                  color: Colors.green,
                ),
                IconButton(
                  onPressed: removeRow,
                  icon: Icon(Icons.remove, color: Colors.black),
                  color: Colors.red,
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
                  child: Text("KEMBALI"),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
                  child: Text("SIMPAN"),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
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
