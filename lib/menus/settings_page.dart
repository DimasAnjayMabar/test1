import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test1/home_page.dart';
import 'package:test1/beans/storage/admin.dart';
import 'package:test1/beans/storage/secure_storage.dart'; // Make sure this page is correct
import 'package:test1/popups/exit/logout_settings.dart';
import 'package:test1/popups/edit/edit_pin.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FocusNode _focusNode = FocusNode();
  String? adminName;

  @override
  void initState() {
    super.initState();
    // Explicitly request focus for the FocusNode
    _focusNode.requestFocus();
    _loadAdminName();
  }

  Future<void> _loadAdminName() async {
    try {
      final adminIdStr = await Admin
          .getAdminCredentials(); // Ambil adminId dari Secure Storage
      if (adminIdStr == null) {
        throw Exception('Admin ID not found');
      }

      final adminId = adminIdStr.id_admin; // Mengubah ke tipe data int
      final adminData = await fetchAdmins(
          adminId); // Kirimkan adminId untuk mendapatkan data admin
      setState(() {
        adminName = adminData['admin_name']; // Ambil nama_admin dari response
      });
    } catch (e) {
      print('Error loading admin name: $e');
    }
  }

  Future<Map<String, dynamic>> fetchAdmins(int adminId) async {
    try {
      final db = await StorageService.getDatabaseIdentity();
      final password = await StorageService.getPassword();

      final response = await http.post(
        Uri.parse('http://${db['serverIp']}:3000/admin'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'server_ip': db['serverIp'],
          'server_username': db['serverUsername'],
          'server_password': password,
          'server_database': db['serverDatabase'],
          'admin_id': adminId
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data == null || data['status'] != 'success') {
          throw Exception(
              'Failed to load admin details: ${data['message']}');
        }

        if (data['admin'] is Map<String, dynamic>) {
          final admin =
              data['admin']; // Langsung akses data karena itu adalah objek
          if (admin['admin_id'] == adminId) {
            return admin; // Kembalikan data admin yang ditemukan
          } else {
            throw Exception('Admin ID mismatch');
          }
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to load admin details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching admin details: $e');
      throw Exception('Error fetching admin details');
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: Text(
          adminName != null
              ? 'Settings - $adminName' // Tampilkan nama admin jika tersedia
              : 'Settings - Loading...', // Placeholder saat data belum dimuat
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF212529),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Icon back
          onPressed: () {
            LogoutSettings.showExitPopup(context);
          },
        ),
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode, // Ensure the FocusNode is passed here
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
            LogoutSettings.showExitPopup(context);
          }
        },
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          physics: BouncingScrollPhysics(), // Enable bounce effect
          child: Column(
            children: [
              // Only one product card here
              ProductCard(
                name: 'Ubah Pin Administrator',
                price: '',
                id: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final String name;
  final String price;

  const ProductCard(
      {super.key, required this.name, required this.price, required id});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _handleTap() {
    setState(() {
      _isPressed = true;
    });

    // Menampilkan dialog VerifyAdmin ketika kartu diklik
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const EditPin(); // Panggil form VerifyAdmin
      },
    ).then((result) {
      // Menangani hasil dari form jika diperlukan (misalnya: kembali ke halaman utama atau refresh data)
      if (result != null && result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pin berhasil diperbarui')),
        );
      }
    });

    // Briefly reset the press state to create a tap effect
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isPressed = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _isPressed
                ? Colors.yellow[700]
                : (_isHovered ? Colors.orange[700] : Colors.grey[900]),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? Colors.orange[300]! : Colors.black26,
                blurRadius: 6,
                spreadRadius: _isHovered ? 2 : 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.price,
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
              const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
