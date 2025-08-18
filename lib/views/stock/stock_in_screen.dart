import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/Controller/stock_controller.dart';
import 'package:inventory_management_app/views/bottomNavBar/MainScreen.dart';

class StockInScreen extends StatelessWidget {
  final StockController controller = Get.put(StockController());

  final TextEditingController costController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();

  StockInScreen({super.key});

 Future<void> addStockDirectly() async {
  if (controller.selectedProductId.value == null ||
      controller.selectedWarehouseId.value == null ||
      costController.text.isEmpty ||
      qtyController.text.isEmpty) {
    Get.snackbar("Error", "Please fill all fields",
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white);
    return;
  }

  final String productId = controller.selectedProductId.value!;
  final String warehouseId = controller.selectedWarehouseId.value!;
  final double costPrice = double.parse(costController.text);
  final int quantity = int.parse(qtyController.text);

  try {
    await controller.addStockInSeparate(productId, warehouseId, costPrice, quantity);

    Get.snackbar("Success", "Stock added successfully",
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white);

    // ✅ After success, go back home and open Dashboard tab
    Get.offAll(() => MainScreen(
      initialIndex: 0,
      allowedScreens: ["dashboard", "inventory", "cashbook", "receivable", "purchase_order" , ],
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
          // ✅ Removed the home action button
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              /// 🔹 Product Dropdown
              Obx(() {
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Select Product",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: controller.selectedProductId.value,
                  items: controller.products
                      .map<DropdownMenuItem<String>>((p) {
                    return DropdownMenuItem(
                        value: p['id'], child: Text(p['name']));
                  }).toList(),
                  onChanged: (val) =>
                      controller.selectedProductId.value = val,
                );
              }),
              SizedBox(height: 10.h),

              /// 🔹 Warehouse Dropdown
              Obx(() {
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Select Warehouse",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: controller.selectedWarehouseId.value,
                  items: controller.warehouses
                      .map<DropdownMenuItem<String>>((w) {
                    return DropdownMenuItem(
                        value: w['id'], child: Text(w['name']));
                  }).toList(),
                  onChanged: (val) =>
                      controller.selectedWarehouseId.value = val,
                );
              }),
              SizedBox(height: 10.h),

              /// 🔹 Cost Price
              TextField(
                controller: costController,
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

              /// 🔹 Quantity
              TextField(
                controller: qtyController,
                decoration: InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20.h),

              /// 🔹 Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: addStockDirectly, // ✅ Save & then go home
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    "Save Stock",
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
