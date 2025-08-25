import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/Controller/stock_controller.dart';

import 'package:inventory_management_app/views/bottomNavBar/MainScreen.dart';

class StockInScreen extends StatelessWidget {
  final StockController controller = Get.put(StockController());

  /// ✅ List of stock entry controllers (for multiple forms)
  final RxList<Map<String, dynamic>> stockEntries = <Map<String, dynamic>>[].obs;

  StockInScreen({super.key}) {
    // Add first stock form by default
    stockEntries.add(_createNewStockEntry());
  }

  /// ✅ Create a new stock entry with controllers
  Map<String, dynamic> _createNewStockEntry() {
    return {
      "productId": RxnString(),
      "warehouseId": RxnString(),
      "costController": TextEditingController(),
      "qtyController": TextEditingController(),
      "noteController": TextEditingController(),
    };
  }

  /// ✅ Add stock(s) to Firebase
  Future<void> addStockDirectly() async {
    try {
      for (var entry in stockEntries) {
        if (entry["productId"].value == null ||
            entry["warehouseId"].value == null ||
            entry["costController"].text.isEmpty ||
            entry["qtyController"].text.isEmpty) {
          Get.snackbar("Error", "Please fill all fields in each stock entry",
              backgroundColor: Colors.redAccent.withOpacity(0.8),
              colorText: Colors.white);
          return;
        }
      }

      // Loop through and add each stock entry
      for (var entry in stockEntries) {
        final String productId = entry["productId"].value!;
        final String warehouseId = entry["warehouseId"].value!;
        final double costPrice =
            double.tryParse(entry["costController"].text) ?? 0.0;
        final int quantity = int.tryParse(entry["qtyController"].text) ?? 0;
        final String note = entry["noteController"].text;

        await controller.addStockInSeparate(
            productId, warehouseId, costPrice, quantity,
            note); // <-- make sure controller handles "note"
      }

      Get.snackbar("Success", "Stock(s) added successfully",
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white);

      // ✅ After success, go back home and open Dashboard tab
      Get.offAll(() => MainScreen(
            initialIndex: 0,
            allowedScreens: [
              "dashboard",
              "inventory",
              "cashbook",
              "receivable",
              "purchase_order",
            ],
            role: "user", // or "admin"
          ));
    } catch (e) {
      Get.snackbar("Error", "Failed to add stock: $e",
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (_, __) => Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            "Stock In",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          elevation: 2,
          backgroundColor: Colors.teal,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Obx(() {
            return SingleChildScrollView(
              child: Column(
                children: [
                  /// 🔹 Dynamic Stock Forms
                  ...stockEntries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            /// Product Dropdown
                            Obx(() {
                              return DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: "Select Product",
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.r)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                value: entry["productId"].value,
                                items: controller.products
                                    .map<DropdownMenuItem<String>>((p) {
                                  return DropdownMenuItem(
                                      value: p['id'], child: Text(p['name']));
                                }).toList(),
                                onChanged: (val) =>
                                    entry["productId"].value = val,
                              );
                            }),
                            SizedBox(height: 10.h),

                            /// Warehouse Dropdown
                            Obx(() {
                              return DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: "Select Warehouse",
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.r)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                value: entry["warehouseId"].value,
                                items: controller.warehouses
                                    .map<DropdownMenuItem<String>>((w) {
                                  return DropdownMenuItem(
                                      value: w['id'], child: Text(w['name']));
                                }).toList(),
                                onChanged: (val) =>
                                    entry["warehouseId"].value = val,
                              );
                            }),
                            SizedBox(height: 10.h),

                            /// Cost Price
                            TextField(
                              controller: entry["costController"],
                              decoration: InputDecoration(
                                labelText: "Cost Price",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 10.h),

                            /// Quantity
                            TextField(
                              controller: entry["qtyController"],
                              decoration: InputDecoration(
                                labelText: "Quantity",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 10.h),

                            /// Note/Description
                            TextField(
                              controller: entry["noteController"],
                              decoration: InputDecoration(
                                labelText: "Note / Description",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  /// ➕ Add Another Stock Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onPressed: () {
                        stockEntries.add(_createNewStockEntry());
                      },
                      icon: const Icon(Icons.add, color: Colors.teal),
                      label: Text(
                        "Add Another Stock",
                        style: TextStyle(
                            color: Colors.teal,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  /// 🔹 Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onPressed: addStockDirectly, // ✅ Save all entries
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        "Save Stock(s)",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
