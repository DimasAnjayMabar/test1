import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _ipController = TextEditingController();
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

    // Here you can replace this with actual logic to verify the IP address
    bool isValid = _ipController.text == '192.168.1.100';  // Example check, replace with actual check

    setState(() {
      _isLoading = false;
      if (isValid) {
        _message = 'Connection successful! Proceeding to Home page...';
      } else {
        _message = 'Invalid IP address, please try again.';
      }
    });

    if (isValid) {
        setState(() {
          _message = 'Koneksi berhasil! Mengarahkan ke menu utama...';
        });
        // Navigate to Home page after a delay
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/home');
        });
      } else {
        setState(() {
          _message = 'IP Lokal tidak terdeteksi, harap mencoba lagi.';
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF212529),  // Base background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Enter Local IP Address',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow, // Yellow title color
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _ipController,
                decoration: InputDecoration(
                  labelText: 'IP Address',
                  labelStyle: TextStyle(color: Colors.yellow), // Yellow label
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow),),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow, width: 2.0),),                  
                  fillColor: Color(0xFF212529),
                  filled: true,
                ),
                style: TextStyle(color: Colors.yellow),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyIP,
                child: Text('Verify', style: TextStyle(color: Color(0xFF212529)),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow, // Yellow button color
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
                        color: Colors.white,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
