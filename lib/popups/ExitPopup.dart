import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test1/WelcomePage.dart';

class Exitpopup {
  static Future<void> showExitPopup(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final FocusNode focusNode = FocusNode();  // Focus node for dialog interaction

        // Wrapping the dialog inside RawKeyboardListener for listening keyboard events
        return RawKeyboardListener(
          focusNode: focusNode,
          onKey: (RawKeyEvent event) {
            // Handle both Escape and Enter key presses
            if (event is RawKeyDownEvent) {
              // Check for Escape key to close dialog
              if (event.logicalKey == LogicalKeyboardKey.escape) {
                Navigator.of(context).pop(); // Close the dialog on Escape
              }
              // Check for Enter key to confirm exit and navigate to WelcomePage
              else if (event.logicalKey == LogicalKeyboardKey.enter) {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomePage()),
                ); // Navigate to WelcomePage on Enter
              }
            }
          },
          child: Focus(
            autofocus: true,  // Ensure focus is granted immediately
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
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => WelcomePage()),
                    ); // Navigate to WelcomePage on Exit
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
