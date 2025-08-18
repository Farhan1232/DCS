import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_management_app/Controller/stock_controller.dart';
import 'package:inventory_management_app/views/stock/stock_in_screen.dart';
import 'package:inventory_management_app/views/stock/stock_out_screen.dart';
import 'package:inventory_management_app/views/utilities/Transaction%20History%20Screen%20%E2%80%93%20transfer_history_screen.dart';
import 'package:inventory_management_app/views/utilities/Transfer%20Screen%20%E2%80%93%20transfer_screen.dart';
import 'package:inventory_management_app/views/utilities/category_screen.dart';
import 'package:inventory_management_app/views/utilities/product_screen.dart';
import 'package:inventory_management_app/views/utilities/warehouse_screen.dart';

class DashboardScreen extends StatelessWidget {
  final StockController controller = Get.find<StockController>();
  final ScrollController _scrollController = ScrollController();

  DashboardScreen({super.key});

  /// 🔹 Function to show Edit/Delete dialog
  void _showEditDialog(
      BuildContext context, Map<String, dynamic> item, String docId) {
    final TextEditingController qtyController =
        TextEditingController(text: item['quantity'].toString());
    final TextEditingController priceController =
        TextEditingController(text: item['price']?.toString() ?? "");

    String selectedWarehouseId = item['warehouseId'];
    String selectedProductId = item['productId'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item['type'] == 'in' ? "Edit Stock In" : "Edit Stock Out"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔹 Warehouse Dropdown
                DropdownButtonFormField<String>(
                  value: selectedWarehouseId,
                  decoration: const InputDecoration(labelText: "Warehouse"),
                  items: controller.warehouses.map((w) {
                    final warehouse = w as Map<String, dynamic>; // ✅ Cast
                    return DropdownMenuItem<String>(
                      value: warehouse['id'].toString(),
                      child: Text(warehouse['name'].toString()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) selectedWarehouseId = val;
                  },
                ),

                /// 🔹 Product Dropdown
                DropdownButtonFormField<String>(
                  value: selectedProductId,
                  decoration: const InputDecoration(labelText: "Product"),
                  items: controller.products.map((p) {
                    final product = p as Map<String, dynamic>; // ✅ Cast
                    return DropdownMenuItem<String>(
                      value: product['id'].toString(),
                      child: Text(product['name'].toString()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) selectedProductId = val;
                  },
                ),

                /// 🔹 Quantity Input
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Quantity"),
                ),

                /// 🔹 Price Input (only for stock in)
                if (item['type'] == 'in')
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Price"),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collectionGroup(
                        item['type'] == 'in' ? 'stock_in' : 'stock_out')
                    .get()
                    .then((query) async {
                  for (var doc in query.docs) {
                    if (doc.id == docId) {
                      await doc.reference.delete();
                      break;
                    }
                  }
                });

                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () async {
                int newQty =
                    int.tryParse(qtyController.text) ?? item['quantity'];
                double? newPrice = item['type'] == 'in'
                    ? double.tryParse(priceController.text)
                    : null;

                // 🔹 Update Firestore
                await FirebaseFirestore.instance
                    .collectionGroup(
                        item['type'] == 'in' ? 'stock_in' : 'stock_out')
                    .get()
                    .then((query) async {
                  for (var doc in query.docs) {
                    if (doc.id == docId) {
                      await doc.reference.update({
                        'warehouseId': selectedWarehouseId,
                        'productId': selectedProductId,
                        'quantity': newQty,
                        if (newPrice != null) 'costPrice': newPrice,
                      });
                      break;
                    }
                  }
                });

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (_, __) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Inventory',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 153, 100, 245),
          elevation: 4,
          actions: [
            IconButton(
              icon: const Icon(Icons.home_work),
              tooltip: "Warehouses",
              onPressed: () => Get.to(() => WarehouseScreen()),
            ),
            IconButton(
              icon: const Icon(Icons.category),
              tooltip: "Categories",
              onPressed: () => Get.to(() => CategoryScreen()),
            ),
            IconButton(
              icon: const Icon(Icons.shopping_bag),
              tooltip: "Products",
              onPressed: () => Get.to(() => ProductScreen()),
            ),
          ],
        ),

        /// 🔹 Stock History
        body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collectionGroup('stock_in').snapshots(),
          builder: (context, inSnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('stock_out')
                  .snapshots(),
              builder: (context, outSnapshot) {
                if (!inSnapshot.hasData || !outSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stockInDocs = inSnapshot.data!.docs;
                final stockOutDocs = outSnapshot.data!.docs;

                final allHistory = [
                  ...stockInDocs.map((d) => {
                        'id': d.id,
                        'type': 'in',
                        'productId': d['productId'],
                        'warehouseId': d['warehouseId'],
                        'quantity': d['quantity'],
                        'price': d['costPrice'] ?? 0,
                        'date': (d['date'] as Timestamp).toDate(),
                      }),
                  ...stockOutDocs.map((d) => {
                        'id': d.id,
                        'type': 'out',
                        'productId': d['productId'],
                        'warehouseId': d['warehouseId'],
                        'quantity': d['quantity'],
                        'price': null,
                        'date': (d['date'] as Timestamp).toDate(),
                      }),
                ];

                allHistory.sort((a, b) => b['date'].compareTo(a['date']));

                Map<String, List<Map<String, dynamic>>> groupedByWarehouse = {};
                for (var item in allHistory) {
                  final warehouseId = item['warehouseId'];
                  if (!groupedByWarehouse.containsKey(warehouseId)) {
                    groupedByWarehouse[warehouseId] = [];
                  }
                  groupedByWarehouse[warehouseId]!.add(item);
                }

                if (allHistory.isEmpty) {
                  return const Center(child: Text("No history available"));
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: groupedByWarehouse.length,
                  itemBuilder: (context, index) {
                    final warehouseId =
                        groupedByWarehouse.keys.elementAt(index);
                    final warehouseItems = groupedByWarehouse[warehouseId]!;

                    final warehouse = controller.warehouses.firstWhereOrNull(
                        (w) => w['id'] == warehouseId);
                    final warehouseName =
                        warehouse?['name'] ?? 'Unknown Warehouse';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        leading: const Icon(Icons.home_work,
                            color: Colors.deepPurple),
                        title: Text(
                          warehouseName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: warehouseItems.map((item) {
                          final product =
                              controller.products.firstWhereOrNull(
                                  (p) => p['id'] == item['productId']);
                          final productName =
                              product?['name'] ?? 'Unknown Product';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: item['type'] == 'in'
                                    ? Colors.green
                                    : Colors.red,
                                child: Icon(
                                  item['type'] == 'in'
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(productName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Quantity: ${item['quantity']}"),
                                  if (item['type'] == 'in')
                                    Text("Price: ${item['price']}"),
                                  Text("Date: ${item['date']}"),
                                ],
                              ),
                              trailing: Text(
                                item['type'] == 'in' ? "IN" : "OUT",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: item['type'] == 'in'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              onTap: () =>
                                  _showEditDialog(context, item, item['id']),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),

        /// 🔹 Floating Action Menu
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          backgroundColor: Colors.deepPurple,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.arrow_downward, color: Colors.white),
              backgroundColor: Colors.green,
              label: "Stock In",
              onTap: () => Get.to(() => StockInScreen()),
            ),
            SpeedDialChild(
              child: const Icon(Icons.arrow_upward, color: Colors.white),
              backgroundColor: Colors.red,
              label: "Stock Out",
              onTap: () => Get.to(() => StockOutScreen()),
            ),
            SpeedDialChild(
              child: const Icon(Icons.swap_horiz, color: Colors.white),
              backgroundColor: Colors.teal,
              label: "Transfer",
              onTap: () => Get.to(() => TransferScreen()),
            ),
            SpeedDialChild(
              child: const Icon(Icons.history, color: Colors.white),
              backgroundColor: Colors.orange,
              label: "Transfer History",
              onTap: () => Get.to(() => TransferHistoryScreen()),
            ),
          ],
        ),
      ),
    );
  }
}
