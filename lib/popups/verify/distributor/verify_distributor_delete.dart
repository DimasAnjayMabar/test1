import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test1/home_page.dart';

class VerifyDistributorDelete {
  static Future<void> showExitPopup(
      BuildContext context, VoidCallback onConfirm) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final FocusNode focusNode = FocusNode();
        return RawKeyboardListener(
          focusNode: focusNode,
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.escape) {
                Navigator.of(context).pop();
              } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                Navigator.of(context).pop();
                onConfirm(); // Jalankan callback
              }
            }
          },
          child: Focus(
            autofocus: true,
            child: AlertDialog(
              title: const Text(
                "Konfirmasi Penghapusan Distributor",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text("Apakah anda yakin ingin menghapus distributor?"),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text(
                    "Tidak",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton(
                  child: const Text(
                    "Ya",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                    onConfirm(); // Jalankan callback
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
