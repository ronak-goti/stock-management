import 'package:flutter/material.dart';
import 'package:practice/drawer/dashboard.dart';
import 'package:practice/drawer/drawer_customer.dart';
import 'package:practice/drawer/drawer_report.dart';
import 'package:practice/drawer/follow_up_remainder_page.dart';
import 'package:practice/drawer/stock_managment.dart';
import 'package:practice/pages/home_page.dart';
import 'package:practice/pages/inventory_page.dart';
import 'package:practice/pages/reporst_page.dart';
import 'package:practice/pages/scan_page.dart';
import 'package:practice/pages/setting_page.dart';
import 'deshboard_page/customer_details.dart';
import 'deshboard_page/follow_up-reminders.dart';
import 'deshboard_page/stock_details.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<Widget> _pages = [
    HomePage(),
    InventoryPage(),
    ScanPage(),
    ReportPage(),
    SettingsPage(),
    StockDetailsScreen(),
    CustomerDetailsScreen(),
    StockReminder(),
    Dashboard(),
    Stock_management(),
    Drawer_customer(),
    Follow_up_remainder(),
    //Drawer_report(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: _buildDrawer(context),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 30),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: !_isSearching
              ? const Text(
            "Stock & CRM Mobile App",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 25,
            ),
          )
              : TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              hintText: "Search...",
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
            onChanged: (value) {},
          ),
        ),
        body: _pages[_selectedIndex],
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: const Icon(Icons.qr_code_scanner,
              size: 28, color: Colors.white),
          onPressed: () => _onTabSelected(2),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, "Home", 0),
                _buildNavItem(Icons.inventory, "Inventory", 1),
                const SizedBox(width: 40),
                _buildNavItem(Icons.bar_chart, "Reports", 3),
                _buildNavItem(Icons.settings, "Setting", 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage("assets/aa.jpg"),
                ),
                const SizedBox(height: 13),
                const Text(
                  "Stock & CRM App",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () {
              _onTabSelected(8);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text("Stock Management"),
            onTap: () {
              _onTabSelected(9);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Customers"),
            onTap: () {
              _onTabSelected(10);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.alarm),
            title: const Text("Follow-up Reminders"),
            onTap: () {
              _onTabSelected(11);
              Navigator.pop(context);
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.bar_chart),
          //   title: const Text("Reports"),
          //   onTap: () {
          //     _onTabSelected(12);
          //     Navigator.pop(context);
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              _onTabSelected(4);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () => _onTabSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? Colors.blue : Colors.black,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: _selectedIndex == index ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}