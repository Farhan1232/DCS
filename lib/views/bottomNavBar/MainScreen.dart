

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/views/Authentication/AdminAccessScreen.dart';
import 'package:inventory_management_app/views/cashbook/cashbook_screen.dart';
import 'package:inventory_management_app/views/dashboard/dashboard_screen.dart';
import 'package:inventory_management_app/views/inventory/inventory_screen.dart';
import 'package:inventory_management_app/views/po/PurchaseOrderScreen.dart';
import 'package:inventory_management_app/views/receivables/receivables_dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  final List<String> allowedScreens;
  final String role;
  final int initialIndex;

  const MainScreen({
    Key? key,
    required this.allowedScreens,
    required this.role,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  late Map<String, Widget> allScreens;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    allScreens = {
      "dashboard": DashboardScreen(role: widget.role),
      "inventory": InventoryScreen(),
      "cashbook": CashBookScreen(),
      "receivable": ReceivablesDashboardScreen(),
      "purchase_order": PurchaseOrderScreen(),
    };
  }

  final Map<String, IconData> screenIcons = {
    "dashboard": Icons.dashboard,
    "inventory": Icons.inventory,
    "cashbook": Icons.book,
    "receivable": Icons.receipt_long,
    "purchase_order": Icons.shopping_cart,
  };

  @override
  Widget build(BuildContext context) {
    List<String> available = widget.allowedScreens;
    List<Widget> screens = available
        .where((s) => allScreens.containsKey(s))
        .map((s) => allScreens[s]!)
        .toList();

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        items: available.map((s) {
          return BottomNavigationBarItem(
            icon: Icon(screenIcons[s] ?? Icons.apps),
            label: s.capitalizeFirst ?? s,
          );
        }).toList(),
      ),
     
    );
  }
}
