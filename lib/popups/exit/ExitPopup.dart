import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test1/beans/user.dart';
import 'package:test1/WelcomePage.dart';

class Exitpopup {
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
              content: const Text("Apakah anda yakin ingin logout? (login ke database dipperlukan setelah logout)"),
              actions: <Widget>[
                //sama halnya dengan focus node, tetapi berbentuk ui
                TextButton(
                  child: const Text(
                    "Kembali",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                TextButton(
                  child: const Text(
                    "Keluar",
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
    //inisialisasi 
    const storage = FlutterSecureStorage();

    try {
      //memanggil user secure storage untuk terakhir kali sebagai penghubung antara aplikasi dan backend
      User? user = await User.getUserCredentials();
      if (user == null) {
        throw Exception("Invalid user credentials or missing server IP.");
      }

      //koneksi ke backend menggunakan server ip
      final serverIp = user.serverIp;
      final response = await http.post(Uri.parse('http://$serverIp:3000/logout'));

      //setelah terkoneksi ke backend, menghapuskan isi dari secure storage
      if (response.statusCode == 200) {
        await storage.delete(key: 'username');
        await storage.delete(key: 'password');
        await storage.delete(key: 'database');
        await storage.delete(key: 'servername');

        Navigator.of(context).pop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to log out. Please try again.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Unable to log out. ${e.toString()}")),
      );
    }
  }
}
