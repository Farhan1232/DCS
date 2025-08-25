import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/Controller/stock_controller.dart';
import 'package:inventory_management_app/views/bottomNavBar/MainScreen.dart';

class MultiStockOutScreen extends StatefulWidget {
  @override
  _MultiStockOutScreenState createState() => _MultiStockOutScreenState();
}

class _MultiStockOutScreenState extends State<MultiStockOutScreen> {
  final StockController controller = Get.find();
  final RxList<Map<String, dynamic>> stockOutItems = <Map<String, dynamic>>[].obs;

  void addNewForm() {
    stockOutItems.add({
      "productId": null,
      "warehouseId": null,
      "qty": "",
      "availableQty": 0, // ✅ available qty field
      "note": "",        // ✅ note field
    });
  }

  Future<void> updateAvailableQty(int index) async {
    final item = stockOutItems[index];
    if (item["productId"] != null && item["warehouseId"] != null) {
      final qty = await controller.getAvailableQuantity(
        item["productId"],
        item["warehouseId"],
      );
      setState(() {
        stockOutItems[index]["availableQty"] = qty;
      });
    }
  }

  Future<void> saveAll() async {
    for (var item in stockOutItems) {
      if (item["productId"] == null ||
          item["warehouseId"] == null ||
          item["qty"].toString().isEmpty) {
        Get.snackbar("Error", "Please fill all fields in every form",
            backgroundColor: Colors.redAccent.withOpacity(0.8),
            colorText: Colors.white);
        return;
      }

      // ✅ validate quantity
      if (int.parse(item["qty"]) > (item["availableQty"] ?? 0)) {
        Get.snackbar("Error", "Not enough stock for ${item["productId"]}",
            backgroundColor: Colors.redAccent.withOpacity(0.8),
            colorText: Colors.white);
        return;
      }

      await controller.addStockOutSeparate(
        item["productId"],
        item["warehouseId"],
        int.parse(item["qty"]),
        item["note"].toString().isNotEmpty ? item["note"] : null, // ✅ save note
      );
    }

    controller.fetchInventory();
    Get.snackbar("Success", "All stock out saved",
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white);
    Get.offAll(() => MainScreen(initialIndex: 0, allowedScreens: [
          "dashboard",
          "inventory",
          "cashbook",
          "receivable",
          "purchase_order"
        ], role: "user"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Multi Stock Out"), backgroundColor: Colors.blueGrey),
      body: Obx(() => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...stockOutItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: "Product"),
                          value: item["productId"],
                          items: controller.products
                              .map<DropdownMenuItem<String>>((p) =>
                                  DropdownMenuItem(value: p['id'], child: Text(p['name'])))
                              .toList(),
                          onChanged: (val) {
                            setState(() => item["productId"] = val);
                            updateAvailableQty(index);
                          },
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: "Warehouse"),
                          value: item["warehouseId"],
                          items: controller.warehouses
                              .map<DropdownMenuItem<String>>((w) =>
                                  DropdownMenuItem(value: w['id'], child: Text(w['name'])))
                              .toList(),
                          onChanged: (val) {
                            setState(() => item["warehouseId"] = val);
                            updateAvailableQty(index);
                          },
                        ),
                        const SizedBox(height: 8),

                        // ✅ Available Qty Display
                        Text(
                          "Available Quantity: ${item["availableQty"]}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blueGrey),
                        ),

                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(labelText: "Quantity"),
                          keyboardType: TextInputType.number,
                          onChanged: (val) => item["qty"] = val,
                        ),
                        const SizedBox(height: 8),

                        // ✅ Note Field
                        TextField(
                          decoration: const InputDecoration(labelText: "Note (optional)"),
                          keyboardType: TextInputType.text,
                          onChanged: (val) => item["note"] = val,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Another"),
                onPressed: addNewForm,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                onPressed: saveAll,
                child: const Text("Save All", style: TextStyle(color: Colors.white)),
              ),
            ],
          )),
    );
  }
}
