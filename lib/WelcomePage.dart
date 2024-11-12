import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Make sure you import this for JSON decoding


class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _databaseController = TextEditingController();
  
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  String _message = '';

  // Method to verify the connection using dynamic IP from the text field
  Future<void> _verifyConnection() async {
    setState(() {
      _isLoading = true;
    });

    // Get the IP address entered by the user
    String serverIp = _ipController.text.trim();
    String username = _usernameController.text.trim();
    String password = _passwordController.text.isEmpty ? '' : _passwordController.text.trim();
    String database = _databaseController.text.trim();

    // Validate the input fields
    if (serverIp.isEmpty || username.isEmpty || database.isEmpty) {
      setState(() {
        _isLoading = false;
        _message = 'Please fill in all the fields';
      });
      return;
    }

    try {
      // Make the HTTP request to the PHP script with the dynamic IP
      final response = await http.post(
        Uri.parse('http://$serverIp/backend/connection.php'), // Use the IP address from the text field
        body: {
          'servername': serverIp,
          'username': username,
          'password': password,
          'database': database,
        },
      );

      // Check if the response was successful
      if (response.statusCode == 200) {
        // Parse the response
        final data = json.decode(response.body);

        setState(() {
          _isLoading = false;
          _message = data['message'];
        });

        if (data['status'] == 'success') {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() {
            _message = 'Failed to connect: ${data['message']}';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _message = 'Failed to connect. Please try again later.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error: $e';
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
            _verifyConnection(); // Trigger connection verification on "Enter" key press
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
                  'Login ke Database Lokal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
                ),
                SizedBox(height: 30),
                
                // IP Address Field
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
                
                // Username Field
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
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
                
                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Hide password input
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                
                // Database Field
                TextField(
                  controller: _databaseController,
                  decoration: InputDecoration(
                    labelText: 'Database',
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
                
                // Verification Button
                ElevatedButton(
                  onPressed: _verifyConnection,
                  child: Text(
                    'Verifikasi',
                    style: TextStyle(color: Color(0xFF212529)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Loading Indicator or Message
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
    _ipController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _databaseController.dispose();
    super.dispose();
  }
}
