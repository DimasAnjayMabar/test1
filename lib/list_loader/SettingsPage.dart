import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test1/HomePage.dart'; // Make sure this page is correct

class Settingspage extends StatefulWidget {
  const Settingspage({super.key});

  @override
  _SettingspageState createState() => _SettingspageState();
}

class _SettingspageState extends State<Settingspage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Explicitly request focus for the FocusNode
    _focusNode.requestFocus();
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
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF212529),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [],
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,  // Ensure the FocusNode is passed here
        onKey: (RawKeyEvent event) {
          // Handle the Escape key press
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              // Navigate to NotesPage when Escape is pressed
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Homepage()),
                (Route<dynamic> route) => false, // Removes all routes until the NotesPage
              );
            }
          }
        },
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          physics: BouncingScrollPhysics(), // Enable bounce effect
          child: Column(
            children: [
              // Only one product card here
              ProductCard(name: 'Ubah Pin Administrator', price: '000000', id: null,),
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

  const ProductCard({super.key, required this.name, required this.price, required id});

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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
