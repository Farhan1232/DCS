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

  void addStockCard() {
    if (controller.selectedProductId.value == null ||
        controller.selectedWarehouseId.value == null ||
        costController.text.isEmpty ||
        qtyController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields",
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white);
      return;
    }

    controller.addStockInItem({
      'productId': controller.selectedProductId.value,
      'warehouseId': controller.selectedWarehouseId.value,
      'costPrice': double.parse(costController.text),
      'quantity': int.parse(qtyController.text),
    });

    costController.clear();
    qtyController.clear();
    controller.selectedProductId.value = null;
    controller.selectedWarehouseId.value = null;
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
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                controller.saveAllStockIn();
                 Get.offAll(() => MainScreen(initialIndex: 0));

              },
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
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

              // Cost Price
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

              // Quantity
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
              SizedBox(height: 10.h),

              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: addStockCard,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    "Add Stock",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Stock List
              Expanded(
                child: Obx(() {
                  if (controller.stockInItems.isEmpty) {
                    return Center(
                      child: Text("No stock items added",
                          style: TextStyle(fontSize: 16.sp)),
                    );
                  }
                  return ListView.builder(
                    itemCount: controller.stockInItems.length,
                    itemBuilder: (context, index) {
                      var item = controller.stockInItems[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 6.h),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12.w),
                          title: Text(
                            "Product: ${item['productId']} - Qty: ${item['quantity']}",
                            style: TextStyle(
                                fontSize: 15.sp, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "Warehouse: ${item['warehouseId']} | Cost: ${item['costPrice']}",
                            style: TextStyle(fontSize: 13.sp),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              controller.removeStockInItem(index);
                            },
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





