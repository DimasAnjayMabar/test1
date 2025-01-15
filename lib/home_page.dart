import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test1/menus/customer_menu.dart';
import 'package:test1/menus/distributor_menu.dart';
import 'package:test1/menus/gudang_menu.dart';
import 'package:test1/menus/hutang_menu.dart';
import 'package:test1/menus/piutang_menu.dart';
import 'package:test1/menus/transaksi_menu.dart';
import 'package:test1/menus/settings_page.dart';
import 'package:test1/popups/exit/logout_app.dart';
import 'package:test1/popups/verify/verify_admin.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final FocusNode _focusNode = FocusNode();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController?.addListener(_onTabChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusNode.requestFocus();
  }

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

  // Fungsi untuk menampilkan dialog VerifyAdmin
  void _showVerifyAdminDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const VerifyAdmin(); // Panggil VerifyAdmin yang sudah diimpor
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212529),
      appBar: AppBar(
        title: const Text('Agus Plastik',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF212529),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: Colors.grey,
            onPressed: () {
              _showVerifyAdminDialog();
            },
          ),
          const SizedBox(width: 8),
          RawKeyboardListener(
            focusNode: _focusNode,
            onKey: (RawKeyEvent event) {
              if (event is RawKeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.escape) {
                LogoutApp.showExitPopup(context);
              }
            },
            child: IconButton(
              icon: const Icon(Icons.exit_to_app),
              color: Colors.grey,
              onPressed: () {
                //memunculkan popup logout
                LogoutApp.showExitPopup(context);
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      //tab bar untuk memilih menu
      body: TabBarView(
        controller: _tabController,
        children: [
          _selectedIndex == 0
              ? const GudangMenu()
              : _buildTab(0,
                  ""), //mengarahkan menu ke loader build gudang untuk memunculkan list produk
          _selectedIndex == 1
              ? const TransaksiMenu()
              : _buildTab(1, ""), //mengarahkan ke loader transaksi
          // _selectedIndex == 2
          //     ? const Buildhutang()
          //     : _buildTab(2, ""), //mengarahkan ke loader hutang
          // _selectedIndex == 3
          //     ? const Buildpiutang()
          //     : _buildTab(3, ""), //mengarahkan ke loader piutang
          _selectedIndex == 2
              ? const DistributorMenu()
              : _buildTab(2,
                  ""), //mengarahkan menu ke loader build distibutor untuk memunculkan list distributor
          // _selectedIndex == 5
          //     ? const Buildcustomer()
          //     : _buildTab(5, "") //mengarahkan ke loader customer
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF212529),
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
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.credit_card_off,
          //       color: _selectedIndex == 2 ? Colors.yellow : Colors.grey[500]),
          //   label: 'Hutang',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.request_quote,
          //       color: _selectedIndex == 3 ? Colors.yellow : Colors.grey[500]),
          //   label: 'Piutang',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping,
                color: _selectedIndex == 2 ? Colors.yellow : Colors.grey[500]),
            label: 'Distributor',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person,
          //       color: _selectedIndex == 5 ? Colors.yellow : Colors.grey[500]),
          //   label: 'Customer',
          // ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String text) {
    return Center(
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black)),
    );
  }
}
