import 'dart:convert'; // Untuk encoding dan decoding JSON
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TempAddBarang {
  String productName;
  double buyPrice;
  int stock;
  double percentProfit;
  String category;

  TempAddBarang({
    required this.productName,
    required this.buyPrice,
    required this.stock,
    required this.percentProfit,
    required this.category,
  });

  static const _storage = FlutterSecureStorage();

  // Save list of products to secure storage
  static Future<void> saveProducts(List<TempAddBarang> products) async {
    List<Map<String, dynamic>> productMaps = products.map((product) {
      return {
        'product_name': product.productName,
        'buy_price': product.buyPrice,
        'stock': product.stock,
        'percent_profit': product.percentProfit,
        'category': product.category,
      };
    }).toList();

    String jsonString = jsonEncode(productMaps); // Convert to JSON string
    await _storage.write(key: 'products', value: jsonString);
  }

  // Retrieve list of products from secure storage
  static Future<List<TempAddBarang>> getProducts() async {
    try {
      String? jsonString = await _storage.read(key: 'products');
      if (jsonString != null) {
        List<dynamic> jsonList = jsonDecode(jsonString); // Decode the JSON
        return jsonList.map((jsonItem) {
          return TempAddBarang(
            productName: jsonItem['product_name'],
            buyPrice: jsonItem['buy_price'],
            stock: jsonItem['stock'],
            percentProfit: jsonItem['percent_profit'],
            category: jsonItem['category'],
          );
        }).toList();
      } else {
        return []; // Return an empty list if no data found
      }
    } catch (e) {
      print('Error retrieving products data: $e');
      return [];
    }
  }

  @override
  String toString() {
    return 'TempProductStorage(productName: $productName, buyPrice: $buyPrice, stock: $stock, percentProfit: $percentProfit, category: $category)';
  }
}
