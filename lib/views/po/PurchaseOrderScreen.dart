import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management_app/Controller/PurchaseOrderController.dart';
import 'PurchaseOrderHistoryScreen.dart';

class PurchaseOrderScreen extends StatelessWidget {
  final PurchaseOrderController controller = Get.put(PurchaseOrderController());

  PurchaseOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: Text(
              "Purchase Orders",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.teal,
            elevation: 4,
            actions: [
              IconButton(
                icon: Icon(Icons.history, color: Colors.white),
                onPressed: () {
                  Get.to(() => PurchaseOrderHistoryScreen());
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form Section
                Text(
                  "Create Purchase Order",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
                SizedBox(height: 10.h),

                // Warehouse Dropdown
                Obx(() => DropdownButtonFormField<String>(
                      value: controller.selectedWarehouseId.value,
                      decoration: InputDecoration(
                        labelText: "Select Warehouse",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      items: controller.warehouses
                          .map((w) => DropdownMenuItem<String>(
                                value: w['id'] as String,
                                child: Text(w['name']),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          controller.selectedWarehouseId.value = val,
                    )),
                SizedBox(height: 20.h),

                // ETA Picker
                Obx(() => Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.eta.value == null
                                ? "Select ETA"
                                : DateFormat("yyyy-MM-dd")
                                    .format(controller.eta.value!),
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today,
                              size: 20.sp, color: Colors.teal),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) controller.eta.value = picked;
                          },
                        )
                      ],
                    )),
                SizedBox(height: 20.h),

                // Product Entries List
                Obx(() => Column(
                      children: List.generate(
                        controller.productEntries.length,
                        (index) {
                          var entry = controller.productEntries[index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 10.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r)),
                            child: Padding(
                              padding: EdgeInsets.all(10.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Dropdown
                                  DropdownButtonFormField<String>(
                                    value: entry['productId'],
                                    decoration: InputDecoration(
                                      labelText: "Select Product",
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                    ),
                                    items: controller.products
                                        .map((p) => DropdownMenuItem<String>(
                                              value: p['id'] as String,
                                              child: Text(p['name']),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      entry['productId'] = val;
                                    },
                                  ),
                                  SizedBox(height: 10.h),

                                  // Quantity
                                  TextField(
                                    controller: entry['qtyController'],
                                    decoration: InputDecoration(
                                      labelText: "Quantity",
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                  SizedBox(height: 10.h),

                                  // Price
                                  TextField(
                                    controller: entry['priceController'],
                                    decoration: InputDecoration(
                                      labelText: "Price",
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),

                                  // Remove button
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: Icon(Icons.delete,
                                          color: Colors.red, size: 22.sp),
                                      onPressed: () {
                                        controller.removeProductEntry(index);
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )),

                // Add Product Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.add, color: Colors.teal),
                    label: Text("Add Product",
                        style:
                            TextStyle(fontSize: 14.sp, color: Colors.teal)),
                    onPressed: controller.addProductEntry,
                  ),
                ),
                SizedBox(height: 20.h),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: controller.createPurchaseOrder,
                    child: Text(
                      "Save Purchase Order",
                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
