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
        final FocusNode focusNode = FocusNode(); // Focus node for dialog interaction

        // Wrapping the dialog inside RawKeyboardListener for listening keyboard events
        return RawKeyboardListener(
          focusNode: focusNode,
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              // Close dialog on Escape
              if (event.logicalKey == LogicalKeyboardKey.escape) {
                Navigator.of(context).pop();
              }
              // Confirm exit and log out on Enter
              else if (event.logicalKey == LogicalKeyboardKey.enter) {
                _handleLogout(context);
              }
            }
          },
          child: Focus(
            autofocus: true, // Ensure focus is granted immediately
            child: AlertDialog(
              title: Text(
                "Confirm Exit",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text("Are you sure you want to exit?"),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                TextButton(
                  child: Text(
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

  static Future<void> _handleLogout(BuildContext context) async {
    final storage = FlutterSecureStorage();

    try {
      // Retrieve user credentials
      User? user = await User.getUserCredentials();
      if (user == null || user.serverIp == null) {
        throw Exception("Invalid user credentials or missing server IP.");
      }

      final serverIp = user.serverIp;
      final response = await http.post(Uri.parse('http://$serverIp:3000/logout'));

      if (response.statusCode == 200) {
        // Delete saved credentials
        await storage.delete(key: 'username');
        await storage.delete(key: 'password');
        await storage.delete(key: 'database');
        await storage.delete(key: 'servername');

        // Successfully logged out, navigate to WelcomePage
        Navigator.of(context).pop(); // Close the dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomePage()),
        );
      } else {
        // Show error message if logout fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to log out. Please try again.")),
        );
      }
    } catch (e) {
      // Handle connection errors or invalid credentials
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Unable to log out. ${e.toString()}")),
      );
    }
  }
}
