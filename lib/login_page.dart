import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:test1/beans/storage/secure_storage.dart';
import 'dart:convert';

//fungsi untuk koneksi aplikasi dengan database
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //controller text field
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _databaseController = TextEditingController();

  //inisialisasi
  final FocusNode _focusNode = FocusNode(); 
  bool _isLoading = false;
  String _message = '';

  Future<void> _verifyConnection() async {
    //inisialisasi ketika gagal login atau lama koneksi ke database
    setState(() {
      _isLoading = true;
    });

    //mendapatkan text dari text field
    String serverIp = _ipController.text.trim();
    String serverUsername = _usernameController.text.trim();
    String serverPassword = _passwordController.text.trim();
    String serverDatabase = _databaseController.text.trim();

    //cek apakah text field kosong
    if (serverIp.isEmpty || serverUsername.isEmpty || serverDatabase.isEmpty) {
      setState(() {
        _isLoading = false;
        _message = 'Please fill in all the fields';
      });
      return;
    }

    //mencoba koneksi ke dalam backend
    try {
      //mengirim identitas databae ke dalam backend body
      final response = await http.post(
        Uri.parse('http://$serverIp:3000/connect'),
        body: {
          'server_ip': serverIp,
          'server_username': serverUsername,
          'server_password': serverPassword,
          'server_database': serverDatabase,
        },
      );
      
      //jika status sukses
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _isLoading = false;
          _message = data['message'];
        });

        if (data['status'] == 'success') {
          await StorageService.saveDatabaseIdentity(
              serverIp: serverIp,
              serverUsername: serverUsername,
              serverDatabase: serverDatabase);
          await StorageService.savePassword(serverPassword);

          //mengalihkan ke homepage
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

//css atau ui
  @override
  Widget build(BuildContext context) {
    //container dari semua child ui
    return Scaffold(
      backgroundColor: const Color(0xFF212529),
      body: RawKeyboardListener(
        //untuk menerima key enter ketika user ingin login
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
                //judul
                const Text(
                  'Selamat Datang di Agus Plastik',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
                ),
                const SizedBox(height: 20),
                //textfield
                TextField(
                  style: const TextStyle(color: Colors.yellow),
                  controller: _ipController,
                  decoration: const InputDecoration(
                    labelText: 'Servername',
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
