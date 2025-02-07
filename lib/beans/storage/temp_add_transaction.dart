import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test1/popups/views/distributor_details.dart';

class TempAddTransaction {
  String selectedDistributor;
  String selectedDate;
  double totalPaid;

  TempAddTransaction({
    required this.selectedDistributor,
    required this.selectedDate,
    required this.totalPaid,
  });

  static const _storage = FlutterSecureStorage();

  // Save product data to secure storage
  static Future<void> saveTransaction(TempAddTransaction temp) async {
    await _storage.write(
        key: 'distributor_name', value: temp.selectedDistributor);
    await _storage.write(key: 'transaction_date', value: temp.selectedDate);
    await _storage.write(key: 'total_paid', value: temp.totalPaid.toString());
  }

  // Retrieve product data from secure storage
  static Future<TempAddTransaction?> getTransaction() async {
    try {
      String? distributorName = await _storage.read(key: 'distributor_name');
      String? transactionDate = await _storage.read(key: 'transaction_date');
      String? totalPaidStr = await _storage.read(key: 'total_paid');

      double totalPaid = double.tryParse(totalPaidStr ?? '0') ?? 0.0;

      return TempAddTransaction(
        selectedDistributor: distributorName ?? '',
        selectedDate: transactionDate ?? '',
        totalPaid: totalPaid,
      );
    } catch (e) {
      print('Error retrieving product data: $e');
      return null;
    }
  }

  @override
  String toString() {
    return 'TempProductStorage(distributorName: $selectedDistributor, Date: $selectedDate, totalPaid: $totalPaid)';
  }
}
