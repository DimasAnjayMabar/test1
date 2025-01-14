import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test1/home_page.dart';

class ExitpopupAdmin {
  static Future<void> showExitPopup(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        //sistem akan mendengarkan key dari inputan keyboard
        final FocusNode focusNode = FocusNode();
        return RawKeyboardListener(
          focusNode: focusNode,
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              //jika escape maka destroy popup ini
              if (event.logicalKey == LogicalKeyboardKey.escape) {
                Navigator.of(context).pop();
              }
              //enter maka logout
              else if (event.logicalKey == LogicalKeyboardKey.enter) {
                _handleLogout(context);
              }
            }
          },
          child: Focus(
            autofocus: true,
            child: AlertDialog(
              title: const Text(
                "Konfirmasi Keluar",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text("Apakah anda yakin ingin logout? (login admin diperlukan ketika mengakses setting)"),
              actions: <Widget>[
                //sama halnya dengan focus node, tetapi berbentuk ui
                TextButton(
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                TextButton(
                  child: const Text(
                    "Exit",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    _handleLogout(context); // Call logout function
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //fungsi untuk logout
  static Future<void> _handleLogout(BuildContext context) async {
    // Inisialisasi secure storage
    const storage = FlutterSecureStorage();

    try {
      // Hapus data admin dari secure storage
      await storage.delete(key: 'username_admin');
      await storage.delete(key: 'password_admin');
      await storage.delete(key: 'id_admin');

      // Navigasi kembali ke halaman WelcomePage atau Homepage
      Navigator.of(context).pop(); // Tutup dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Unable to log out. ${e.toString()}")),
      );
    }
  }
}
