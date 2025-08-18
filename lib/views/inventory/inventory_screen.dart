import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:inventory_management_app/Controller/LoginController.dart';
import 'package:inventory_management_app/Controller/stock_controller.dart';
import 'package:inventory_management_app/views/Authentication/AdminAccessScreen.dart';

class DashboardScreen extends StatefulWidget {
  final String role; // ✅ role comes from MainScreen

  const DashboardScreen({super.key, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StockController controller = Get.put(StockController());
   final LoginController loginController = Get.put(LoginController());

  final RxString selectedWarehouse = "Warehouse".obs;
  final RxString selectedView = "View".obs;
  final RxString selectedProduct = "Search".obs;
  final RxString selectedCategory = "Category".obs;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (_, __) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
         appBar: AppBar(
  title: const Text("Dashboard"),
  centerTitle: true,
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.teal, Colors.green],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
  actions: [
    if (widget.role == "admin") // ✅ Show only if admin
      IconButton(
        icon: const Icon(Icons.admin_panel_settings,color: Color.fromARGB(255, 194, 247, 49),),
        tooltip: "Admin Access",
        onPressed: () {
          Get.to(() => AdminAccessScreen());
        },
      ),
    
      IconButton(
            icon: Icon(Icons.logout,color: Colors.red,),
            tooltip: "Logout",
            onPressed: () {
              // Optional: confirmation dialog before logout
              Get.defaultDialog(
                title: "Logout",
                middleText: "Are you sure you want to logout?",
                textCancel: "No",
                textConfirm: "Yes",
                confirmTextColor: Colors.white,
                onConfirm: () {
                  loginController.logout(); // ✅ call logout from your controller
                },
              );
            },
          ),
  ],
),

          body: Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              children: [
                SizedBox(height: 10.h),

                /// 🔽 Filter bar
                Obx(() => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildDropdown(
                            value: selectedWarehouse.value,
                            items: [
                              "Warehouse",
                              ...controller.warehouses
                                  .map((w) => w['name'].toString())
                            ],
                            onChanged: (val) =>
                                selectedWarehouse.value = val ?? "Warehouse",
                          ),
                          _buildDropdown(
                            value: selectedView.value,
                            items: ["View", "Table"],
                            onChanged: (val) =>
                                selectedView.value = val ?? "View",
                          ),
                          _buildDropdown(
                            value: selectedProduct.value,
                            items: [
                              "Search",
                              ...controller.products
                                  .map((p) => p['name'].toString())
                            ],
                            onChanged: (val) =>
                                selectedProduct.value = val ?? "Search",
                          ),
                          _buildDropdown(
                            value: selectedCategory.value,
                            items: [
                              "Category",
                              ...controller.categories
                                  .map((c) => c['name'].toString())
                            ],
                            onChanged: (val) =>
                                selectedCategory.value = val ?? "Category",
                          ),
                        ],
                      ),
                    )),

                SizedBox(height: 20.h),

                /// 📦 Inventory View
                Expanded(
                  child: Obx(() {
                    var filteredInventory = controller.inventory.where((item) {
                      bool matchesWarehouse =
                          selectedWarehouse.value == "Warehouse"
                              ? true
                              : item['warehouseName']?.toString().toLowerCase() ==
                                  selectedWarehouse.value.toLowerCase();

                      bool matchesProduct = selectedProduct.value == "Search"
                          ? true
                          : item['productName']?.toString().toLowerCase() ==
                              selectedProduct.value.toLowerCase();

                      final product = controller.products.firstWhereOrNull(
                          (p) => p['name'] == item['productName']);
                      final categoryId = product?['categoryId'];
                      final category = controller.categories
                          .firstWhereOrNull((c) => c['id'] == categoryId);
                      final categoryName =
                          category != null ? category['name'] : "Unknown";

                      bool matchesCategory =
                          selectedCategory.value == "Category"
                              ? true
                              : categoryName.toLowerCase() ==
                                  selectedCategory.value.toLowerCase();

                      return matchesWarehouse &&
                          matchesProduct &&
                          matchesCategory;
                    }).toList();

                    if (selectedView.value == "Table") {
                      if (filteredInventory.isEmpty) {
                        return const Center(
                            child: Text("No stock available"));
                      }

                      final warehouseList = controller.warehouses
                          .map((w) => w['name'].toString())
                          .toList();
                      final Map<String, Map<String, dynamic>> pivotData = {};

                      for (var item in filteredInventory) {
                        final productName = item['productName'].toString();
                        final product = controller.products.firstWhereOrNull(
                            (p) => p['name'] == productName);
                        final categoryId = product?['categoryId'];
                        final category = controller.categories.firstWhereOrNull(
                            (c) => c['id'] == categoryId);
                        final categoryName =
                            category != null ? category['name'] : "Unknown";

                        pivotData.putIfAbsent(productName, () => {
                              'categoryName': categoryName,
                            });

                        final whName = item['warehouseName'].toString();
                        final qty = item['quantity'] ?? item['qty'] ?? 0;
                        pivotData[productName]![whName] = qty;
                      }

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: DataTable2(
                            columnSpacing: 12.w,
                            horizontalMargin: 12.w,
                            minWidth: 200.w +
                                (warehouseList.length * 100.w) +
                                100.w,
                            columns: [
                              const DataColumn(label: Text("Product")),
                              const DataColumn(label: Text("Price")),
                              ...warehouseList
                                  .map((wh) => DataColumn(label: Text(wh))),
                              const DataColumn(label: Text("Total")),
                            ],
                            rows: pivotData.entries.map((entry) {
                              final productName = entry.key;

                              final price = (filteredInventory.firstWhereOrNull(
                                          (inv) =>
                                              inv['productName'] == productName)?[
                                      'price']) ??
                                  0;

                              final totalQty = warehouseList.fold<int>(
                                0,
                                (sum, wh) =>
                                    sum +
                                    ((entry.value[wh] ?? 0) as num).toInt(),
                              );

                              return DataRow(
                                color: MaterialStateProperty.resolveWith<Color?>(
                                  (states) =>
                                      entry.key.hashCode.isEven
                                          ? Colors.grey[100]
                                          : null,
                                ),
                                cells: [
                                  DataCell(Text(productName)),
                                  DataCell(Text(price.toString())),
                                  ...warehouseList.map((wh) {
                                    final qty = entry.value[wh] ?? 0;
                                    return DataCell(Text(qty.toString()));
                                  }),
                                  DataCell(Text(totalQty.toString())),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    } else {
                      return ListView(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Text("Current Inventory",
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold)),
                          ),
                          if (filteredInventory.isEmpty)
                            const Center(child: Text("No stock available")),
                          ...filteredInventory.map((item) {
                            final qty = item['quantity'] ?? item['qty'] ?? 0;
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(
                                  vertical: 6.h, horizontal: 8.w),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r)),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(12.w),
                                title: Text(item['productName'] ??
                                    "Unknown Product"),
                                subtitle: Text(
                                  "Warehouse: ${item['warehouseName'] ?? "Unknown"}\n"
                                  "Qty: $qty",
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    }
                  }),
                ),
              ],
            ),
          ),

          
        );
      },
    );
  }

  /// 🔽 Reusable dropdown
  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        onChanged: onChanged,
        items: items
            .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: TextStyle(fontSize: 14.sp))))
            .toList(),
      ),
    );
  }
}
