import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test1/list_loader/BuildGudang.dart';
import 'package:test1/list_loader/BuildHutang.dart';
import 'package:test1/list_loader/BuildPiutang.dart';
import 'package:test1/list_loader/BuildTransaksi.dart';
import 'package:test1/list_loader/SettingsPage.dart';
import 'package:test1/popups/ExitPopup.dart';

class Homepage extends StatefulWidget {
  @override
  HomepageState createState() => HomepageState();
}

class HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final FocusNode _focusNode = FocusNode();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize TabController for managing tabs
    _tabController = TabController(length: 4, vsync: this);
    _tabController?.addListener(_onTabChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusNode.requestFocus(); // Request focus to enable key listener
  }

  // Update the selected index based on tab change
  void _onTabChanged() {
    setState(() {
      _selectedIndex = _tabController!.index;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF212529),
      appBar: AppBar(
        title: Text('Agus Plastik',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF212529),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            color: Colors.grey,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Settingspage()));
            },
          ),
          SizedBox(width: 8),
          RawKeyboardListener(
            focusNode: _focusNode,
            onKey: (RawKeyEvent event) {
              if (event is RawKeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.escape) {
                Exitpopup.showExitPopup(
                    context); // Trigger popup on Escape key press
              }
            },
            child: IconButton(
              icon: Icon(Icons.exit_to_app),
              color: Colors.grey,
              onPressed: () {
                Exitpopup.showExitPopup(context);
              },
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _selectedIndex == 0 ? Buildgudang() : _buildTab(0, ""),
          _selectedIndex == 1 ? Buildtransaksi() : _buildTab(1, ""),
          _selectedIndex == 2 ? Buildhutang() : _buildTab(2, ""),
          _selectedIndex == 3 ? Buildpiutang() : _buildTab(3, "")
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF212529),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _tabController?.animateTo(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.warehouse,
                color: _selectedIndex == 0 ? Colors.yellow : Colors.grey[500]),
            label: 'Gudang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart,
                color: _selectedIndex == 1 ? Colors.yellow : Colors.grey[500]),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_off,
                color: _selectedIndex == 2 ? Colors.yellow : Colors.grey[500]),
            label: 'Hutang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_quote,
                color: _selectedIndex == 3 ? Colors.yellow : Colors.grey[500]),
            label: 'Piutang',
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String text) {
    return Center(
      child: Text(text,
          textAlign: TextAlign.center, style: TextStyle(color: Colors.black)),
    );
  }
}
