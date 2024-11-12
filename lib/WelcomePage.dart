import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _ipController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  String _message = '';

  // Method to simulate IP address verification (replace with actual logic)
  Future<void> _verifyIP() async {
    setState(() {
      _isLoading = true;
      _message = 'Verifying...';
    });

    // Simulate a network call delay
    await Future.delayed(Duration(seconds: 2));

    // Example check for IP validation (replace with actual logic)
    bool isValid = _ipController.text == '192.168.1.100';

    setState(() {
      _isLoading = false;
      if (isValid) {
        _message = 'Koneksi berhasil! Mengarahkan ke menu utama...';
      } else {
        _message = 'IP Lokal tidak terdeteksi, harap mencoba lagi.';
      }
    });

    if (isValid) {
      // Navigate to Home page after a delay
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus(); // Request focus to enable key listener
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF212529),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
            _verifyIP(); // Trigger verification on "Enter" key press
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Selamat Datang di Agus Plastik',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
                ),
                Text(
                  'Masukkan IP Server Lokal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _ipController,
                  decoration: InputDecoration(
                    labelText: 'IP Address',
                    labelStyle: TextStyle(color: Colors.yellow),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow, width: 2.0),
                    ),
                    fillColor: Color(0xFF212529),
                    filled: true,
                  ),
                  style: TextStyle(color: Colors.yellow),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _verifyIP,
                  child: Text(
                    'Verify',
                    style: TextStyle(color: Color(0xFF212529)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                  ),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                      )
                    : Text(
                        _message,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.yellow,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose focus node to avoid memory leaks
    _ipController.dispose(); // Dispose controller when not needed
    super.dispose();
  }
}
