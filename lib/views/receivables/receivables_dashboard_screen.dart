import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/Controller/receivable_controller.dart';
import 'package:inventory_management_app/views/receivables/Add%20ClosedReceivablesScreen.dart';
import 'package:inventory_management_app/views/receivables/add_receivable_screen.dart';
import 'package:inventory_management_app/views/receivables/receivable_detail_screen.dart';

class ReceivablesDashboardScreen extends StatelessWidget {
  final ReceivableController ctrl = Get.put(ReceivableController());

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 12 size for scaling
      builder: (_, __) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.teal,
            elevation: 4,
            title: Text(
              'Receivables',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add, size: 24.sp, color: Colors.white),
                onPressed: () => Get.to(() => AddReceivableScreen()),
              ),
              IconButton(
                icon: Icon(Icons.check_circle, size: 24.sp, color: Colors.white),
                onPressed: () => Get.to(() => ClosedReceivablesScreen()),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(12.w),
            child: Obx(() {
              // 🔹 Show only "open" receivables
              final list = ctrl.receivables
                  .where((r) => r.status.toLowerCase() == "open")
                  .toList();

              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'No Open Receivables',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (context, i) {
                  final r = list[i];
                  final dueText = r.dueDate != null
                      ? '${r.dueDate!.toLocal().toString().split(' ')[0]}'
                      : 'No due date';

                  return InkWell(
                    onTap: () {
                      Get.to(() => ReceivableDetailScreen(), arguments: r);
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
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
                            backgroundColor: Colors.teal.withOpacity(0.15),
                            child: Icon(
                              Icons.person,
                              color: Colors.teal,
                              size: 22.sp,
                            ),
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
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Outstanding: د.إ ${r.outstanding.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Due: $dueText',
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
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              r.status,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        );
      },
    );
  }
}
