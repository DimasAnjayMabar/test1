import 'dart:convert';  // For json encoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test1/beans/user.dart';

class ProductPopup {
  static Future<void> showProductPopup(BuildContext context, String productId) async {
    try {
      // Retrieve saved user credentials from storage
      final storage = const FlutterSecureStorage();
      User? user = await User.getUserCredentials();

      if (user == null) {
        throw Exception('No user data found');
      }

      final serverIp = user.serverIp; // Get server IP from the saved user object

      // Make a POST request to fetch the product details
      final response = await http.post(
        Uri.parse('http://$serverIp:3000/products'), // Use your server's endpoint
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'servername': serverIp,
          'username': user.username, // Use saved username
          'password': user.password, // Use saved password
          'database': user.database, // Use saved database name
          'productId': productId, // Send the productId to fetch details for a specific product
        }),
      );

      if (response.statusCode == 200) {
        // Assuming the response body contains a JSON object with the product details
        final productData = parseProductData(response.body);

        // Show popup with product details
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Product Details"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: ${productData['nama_barang']}"),
                    Text("Purchase Price: ${productData['harga_beli']}"),
                    Text("Selling Price: ${productData['harga_jual']}"),
                    Text("Entry Date: ${productData['tanggal_masuk']}"),
                    Text("Stock: ${productData['stok']}"),
                    Text("Barcode: ${productData['barcode']}"),
                    Text("Debt: ${productData['hutang'] ? 'Yes' : 'No'}"),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      } else {
        // Handle error when data can't be fetched
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load product details. Please try again.")),
        );
      }
    } catch (e) {
      // Handle connection or parsing errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Unable to load product details. ${e.toString()}")),
      );
    }
  }

  // Method to parse the product data from the server response
  static Map<String, dynamic> parseProductData(String responseBody) {
    // Assuming the response is JSON
    final jsonData = jsonDecode(responseBody);
    return jsonData;
  }
}
