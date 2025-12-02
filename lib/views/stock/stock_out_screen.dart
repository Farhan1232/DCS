import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/Controller/stock_controller.dart';
import 'package:inventory_management_app/views/bottomNavBar/MainScreen.dart';
import 'package:inventory_management_app/views/stock/MultiStockOutScreen.dart';

class StockOutScreen extends StatelessWidget {
  final StockController controller = Get.put(StockController());
  String? selectedProductId;
  String? selectedWarehouseId;
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController noteController = TextEditingController(); // ✅ New
  var availableQty = 0.obs;

  void updateAvailableQty() async {
    if (selectedProductId != null && selectedWarehouseId != null) {
      availableQty.value = await controller.getAvailableQuantity(
        selectedProductId!,
        selectedWarehouseId!,
      );
    }
  }

  void saveStockOut() async {
    if (selectedProductId == null ||
        selectedWarehouseId == null ||
        qtyController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields",
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white);
      return;
    }

    if (int.parse(qtyController.text) > availableQty.value) {
      Get.snackbar("Error", "Not enough stock available",
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white);
      return;
    }

    await controller.addStockOutSeparate(
      selectedProductId!,
      selectedWarehouseId!,
      int.parse(qtyController.text),
      noteController.text.isNotEmpty ? noteController.text : null, // ✅ Save note
    );

    controller.fetchInventory();

    qtyController.clear();
    noteController.clear(); // ✅ Clear note field
    availableQty.value = 0;

    Get.snackbar("Success", "Stock Out saved and inventory updated",
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white);

    // ✅ Navigate back to Dashboard (index 0)
    Get.offAll(() => MainScreen(
          initialIndex: 0,
          allowedScreens: [
            "dashboard",
            "inventory",
            "cashbook",
            "receivable",
            "purchase_order"
          ],
          role: "user",
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (_, __) => Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            "Stock Out",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          elevation: 2,
          backgroundColor: Colors.deepOrange,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Dropdown
              Obx(() {
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Select Product",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: selectedProductId,
                  items:
                      controller.products.map<DropdownMenuItem<String>>((p) {
                    return DropdownMenuItem(
                        value: p['id'], child: Text(p['name']));
                  }).toList(),
                  onChanged: (val) {
                    selectedProductId = val;
                    updateAvailableQty();
                  },
                );
              }),
              SizedBox(height: 12.h),

              // Warehouse Dropdown
              Obx(() {
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Select Warehouse",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: selectedWarehouseId,
                  items:
                      controller.warehouses.map<DropdownMenuItem<String>>((w) {
                    return DropdownMenuItem(
                        value: w['id'], child: Text(w['name']));
                  }).toList(),
                  onChanged: (val) {
                    selectedWarehouseId = val;
                    updateAvailableQty();
                  },
                );
              }),
              SizedBox(height: 12.h),

              // Available Quantity
              Obx(() => Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Text(
                      "Available Quantity: ${availableQty.value}",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                  )),
              SizedBox(height: 12.h),

              // Quantity Input
              TextField(
                controller: qtyController,
                decoration: InputDecoration(
                  labelText: "Quantity to remove",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12.h),

              // ✅ Note Input
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: "Note (optional)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 20.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: saveStockOut,
                  child: Text(
                    "Save",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // ✅ New Multi Stock Out Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: () {
                    Get.to(() => MultiStockOutScreen()); // 👈 new page
                  },
                  child: Text(
                    "Multi Stock Out",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
