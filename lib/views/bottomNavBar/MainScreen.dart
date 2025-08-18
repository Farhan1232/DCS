import 'package:flutter/material.dart';

import 'package:inventory_management_app/views/cashbook/cashbook_screen.dart';
import 'package:inventory_management_app/views/dashboard/dashboard_screen.dart';
import 'package:inventory_management_app/views/inventory/inventory_screen.dart';
import 'package:inventory_management_app/views/po/PurchaseOrderScreen.dart';
import 'package:inventory_management_app/views/receivables/receivables_dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex; // ✅ add this

  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    InventoryScreen(),
    DashboardScreen(),
    CashBookScreen(),
    ReceivablesDashboardScreen(),
    PurchaseOrderScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // ✅ use initialIndex here
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Inventory'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Cashbook'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Receivable'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Purchase Order'),
        ],
      ),
    );
  }
}
