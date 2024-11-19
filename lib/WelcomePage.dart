import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/user.dart';
import 'dart:convert';

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

  Future<void> _verifyConnection() async {
    setState(() {
      _isLoading = true;
    });

    String serverIp = _ipController.text.trim();
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String database = _databaseController.text.trim();

    if (serverIp.isEmpty || username.isEmpty || database.isEmpty) {
      setState(() {
        _isLoading = false;
        _message = 'Please fill in all the fields';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://$serverIp:3000/connect'),
        body: {
          'servername': serverIp,
          'username': username,
          'password': password,
          'database': database,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _isLoading = false;
          _message = data['message'];
        });

        if (data['status'] == 'success') {
          // Add user to global list
          userList.add(User(
            serverIp: serverIp,
            username: username,
            password: password,
            database: database,
          ));

          // Navigate to ProductsPage
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF212529),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
            _verifyConnection();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Selamat Datang di Agus Plastik',
                  style: TextStyle(
                    fontSize: 30,
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
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.yellow),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.yellow),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _databaseController,
                  decoration: InputDecoration(
                    labelText: 'Database',
                    labelStyle: TextStyle(color: Colors.yellow),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _verifyConnection,
                  child: Text('Verifikasi'),
                ),
                SizedBox(height: 20),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  Text(
                    _message,
                    style: TextStyle(color: Colors.yellow),
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
    _ipController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _databaseController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
