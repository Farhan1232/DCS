import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/Controller/receivable_controller.dart';

class ClosedReceivablesScreen extends StatelessWidget {
  final ReceivableController ctrl = Get.find<ReceivableController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Closed Receivables",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: Obx(() {
          final closedList = ctrl.receivables
              .where((r) => r.status.toLowerCase() == "closed")
              .toList();

          if (closedList.isEmpty) {
            return Center(
              child: Text(
                "No Closed Receivables",
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            itemCount: closedList.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, i) {
              final r = closedList[i];
              final dueText = r.dueDate != null
                  ? r.dueDate!.toLocal().toString().split(' ')[0]
                  : "No due date";

              return Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: Colors.redAccent.withOpacity(0.15),
                      child: Icon(Icons.person, color: Colors.redAccent),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.customerName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Outstanding: د.إ ${r.outstanding.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "Due: $dueText",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        "Closed",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
