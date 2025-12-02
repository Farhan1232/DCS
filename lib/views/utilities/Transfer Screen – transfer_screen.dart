import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory_management_app/Controller/transfer_controller.dart';

class TransferScreen extends StatelessWidget {
  final TransferController controller = Get.put(TransferController());
  final TextEditingController qtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (_, __) => Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            "Stock Transfer",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          elevation: 3,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // From Warehouse Dropdown
                  Obx(() => DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'From Warehouse',
                          labelStyle: TextStyle(fontSize: 14.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 10.h),
                        ),
                        value: controller.selectedFromWarehouse.value,
                        items: controller.warehouses
                            .map((w) => DropdownMenuItem<String>(
                                  value: w['id'],
                                  child: Text(w['name'],
                                      style: TextStyle(fontSize: 14.sp)),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            controller.selectedFromWarehouse.value = val,
                      )),
                  SizedBox(height: 12.h),

                  // To Warehouse Dropdown
                  Obx(() => DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'To Warehouse',
                          labelStyle: TextStyle(fontSize: 14.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 10.h),
                        ),
                        value: controller.selectedToWarehouse.value,
                        items: controller.warehouses
                            .map((w) => DropdownMenuItem<String>(
                                  value: w['id'],
                                  child: Text(w['name'],
                                      style: TextStyle(fontSize: 14.sp)),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            controller.selectedToWarehouse.value = val,
                      )),
                  SizedBox(height: 12.h),

                  // Product Dropdown
                  Obx(() => DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Product',
                          labelStyle: TextStyle(fontSize: 14.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 10.h),
                        ),
                        value: controller.selectedProduct.value,
                        items: controller.products
                            .map((p) => DropdownMenuItem<String>(
                                  value: p['id'],
                                  child: Text(p['name'],
                                      style: TextStyle(fontSize: 14.sp)),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            controller.selectedProduct.value = val,
                      )),
                  SizedBox(height: 12.h),

                  // Quantity Input
                  TextFormField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Quantity",
                      labelStyle: TextStyle(fontSize: 14.sp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                    ),
                    onChanged: (val) =>
                        controller.quantity.value = int.tryParse(val) ?? 0,
                  ),
                  SizedBox(height: 20.h),

                  // Transfer Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onPressed: () => controller.transferStock(),
                      child: Text(
                        "Transfer Stock",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
