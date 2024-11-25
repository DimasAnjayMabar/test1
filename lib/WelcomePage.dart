import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/user.dart';
import 'dart:convert';


class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

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

    // Validate fields before attempting to connect
    if (serverIp.isEmpty || username.isEmpty || database.isEmpty) {
      setState(() {
        _isLoading = false;
        _message = 'Please fill in all the fields';
      });
      return;
    }

    try {
      // Send POST request to backend to verify database connection
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

        // Successful connection
        if (data['status'] == 'success') {
          // Save credentials securely in storage
          await User.saveUserCredentials(User(
            serverIp: serverIp,
            username: username,
            password: password,
            database: database,
          ));

          // // Store connection information in session (optional)
          // await _storeConnectionInSession(serverIp, username, password, database);

          // Navigate to Home page
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

  // Future<void> _storeConnectionInSession(
  //   String serverIp, String username, String password, String database) async {
  //   try {
  //     // Send the session information to the backend to be saved in the user's session
  //     final response = await http.post(
  //       Uri.parse('http://$serverIp:3000/store-session'),
  //       body: {
  //         'servername': serverIp,
  //         'username': username,
  //         'password': password,
  //         'database': database,
  //       },
  //     );
  //     if (response.statusCode != 200) {
  //       print('Failed to store session data');
  //     }
  //   } catch (e) {
  //     print('Error storing session: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212529),
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
                const Text(
                  'Selamat Datang di Agus Plastik',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  style: const TextStyle(color: Colors.yellow),
                  controller: _ipController,
                  decoration: const InputDecoration(
                    labelText: 'IP Address',
                    labelStyle: TextStyle(color: Colors.yellow),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  style: const TextStyle(color: Colors.yellow),
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.yellow),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  style: const TextStyle(color: Colors.yellow),
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.yellow),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  style: const TextStyle(color: Colors.yellow),
                  controller: _databaseController,
                  decoration: const InputDecoration(
                    labelText: 'Database',
                    labelStyle: TextStyle(color: Colors.yellow),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _verifyConnection,
                  child: const Text('Verifikasi'),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Text(
                    _message,
                    style: const TextStyle(color: Colors.yellow),
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
