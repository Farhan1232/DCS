
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // 👈 for date & time formatting
import 'package:inventory_management_app/Controller/PurchaseOrderController.dart';
import 'package:inventory_management_app/Controller/stock_controller.dart';


class PurchaseOrderHistoryScreen extends StatelessWidget {
  final PurchaseOrderController controller = Get.find();
  final StockController stockController = Get.find();

  PurchaseOrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Purchase Order History",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Obx(() {
        var pendingOrders = controller.purchaseOrders
            .where((po) => po['status'].toString().toLowerCase() != "received")
            .toList();

        var receivedOrders = controller.purchaseOrders
            .where((po) => po['status'].toString().toLowerCase() == "received")
            .toList();

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pending Section
              Text(
                "Pending Orders",
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),
              SizedBox(height: 10.h),
              ...pendingOrders.map((po) => buildOrderCard(po, false)),

              SizedBox(height: 20.h),
              Divider(),

              // Received Section
              Text(
                "Received Orders",
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              SizedBox(height: 10.h),
              ...receivedOrders.map((po) => buildOrderCard(po, true)),
            ],
          ),
        );
      }),
    );
  }

  Widget buildOrderCard(Map<String, dynamic> po, bool isReceived) {
    List items = po['items'] ?? [];

    // ✅ Convert ETA into formatted date & time
    DateTime? etaDate;
    try {
      if (po['eta'] is String) {
        etaDate = DateTime.tryParse(po['eta']);
      } else if (po['eta'] is Timestamp) {
        etaDate = (po['eta'] as Timestamp).toDate();
      }
    } catch (_) {}

    String etaText = etaDate != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(etaDate)
        : po['eta'].toString();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Warehouse: ${po['warehouseName']}",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            Text("ETA: $etaText", style: TextStyle(fontSize: 14.sp)), // 👈 formatted ETA
            Text(
              "Status: ${po['status']}",
              style: TextStyle(
                  fontSize: 14.sp,
                  color: isReceived ? Colors.green : Colors.orange),
            ),
            SizedBox(height: 8.h),

            // Show each product
            ...items.map((item) {
              int orderedQty = item['qty'];
              int receivedQty = item['receivedQty'] ?? 0;
              return ListTile(
                title: Text("${item['productName']}"),
                subtitle: Text("Ordered: $orderedQty | Received: $receivedQty"),
                trailing: !isReceived
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: () {
                          int receiveQty = 0;
                          Get.defaultDialog(
                            title: "Enter Received Quantity",
                            content: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (val) =>
                                  receiveQty = int.tryParse(val) ?? 0,
                            ),
                            textConfirm: "Confirm",
                            textCancel: "Cancel",
                            onConfirm: () async {
                              if (receiveQty > 0) {
                                Get.back(); // 👈 Close dialog instantly
                                // 1️⃣ Update PO (mark as received)
                                await controller.markAsReceived(po['id'], po, {
                                  item['productId']: receiveQty
                                });

                                // 2️⃣ Update Stock In (merge by product + warehouse)
                                await stockController.addStockIn(
                                  item['productId'],
                                  po['warehouseId'],
                                  (item['price'] as num).toDouble(),
                                  receiveQty,
                                  null,
                                  
                                  
                                );
                              }
                            },
                          );
                        },
                        child: Text("Receive"),
                      )
                    : null,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
