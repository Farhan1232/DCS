import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/Controller/receivable_controller.dart';
import 'package:inventory_management_app/services/firestore_service.dart';

class ReceivableDetailScreen extends StatelessWidget {
  final ReceivableController ctrl = Get.find<ReceivableController>();

  @override
  Widget build(BuildContext context) {
    final r = Get.arguments;
    final receivableId = r.id;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Receivable Detail',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: Get.find<FirestoreService>().getReceivable(receivableId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data as Map<String, dynamic>;
                final outstanding = (data['outstanding'] ?? 0).toDouble();
                final total = (data['totalAmount'] ?? 0).toDouble();
                final due = data['dueDate'] != null
                    ? (data['dueDate'] as Timestamp).toDate()
                    : null;

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  elevation: 3,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer: ${data['customerName']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.sp),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Total: د.إ ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 14.sp, color: Colors.green[800]),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Outstanding: د.إ ${outstanding.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 14.sp, color: Colors.redAccent),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Due: ${due != null ? due.toLocal().toString().split(' ')[0] : '—'}',
                          style:
                              TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Notes: ${data['notes'] ?? ''}',
                          style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r)),
                                ),
                                icon: Icon(Icons.add, size: 18.sp),
                                label: Text("Add Payment",
                                    style: TextStyle(fontSize: 14.sp)),
                                onPressed: () {
                                  _showAddPaymentDialog(context, receivableId);
                                },
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r)),
                                ),
                                icon: Icon(Icons.edit, size: 18.sp),
                                label: Text("Adjust Amount",
                                    style: TextStyle(fontSize: 14.sp)),
                                onPressed: () {
                                  _showAdjustDialog(context, receivableId);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Payment History',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15.sp),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: ctrl.paymentsStream(receivableId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final list = snapshot.data!;
                  if (list.isEmpty) {
                    return Center(
                        child: Text('No payments yet',
                            style: TextStyle(fontSize: 14.sp)));
                  }
                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (context, i) {
                      final p = list[i];
                      final ts = p['timestamp'] as Timestamp?;
                      final date = ts != null
                          ? ts.toDate().toLocal().toString().split('.')[0]
                          : '';
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          title: Text(
                            '${p['type']} • د.إ ${(p['amount'] ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          subtitle: Text(
                            '${p['note'] ?? ''}',
                            style: TextStyle(fontSize: 13.sp),
                          ),
                          trailing: Text(
                            date,
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.grey[600]),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context, String receivableId) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Payment', style: TextStyle(fontSize: 16.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Amount (د.إ)'),
            ),
            TextField(
              controller: noteCtrl,
              decoration: InputDecoration(labelText: 'Note (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              final amt = double.tryParse(amountCtrl.text) ?? 0;
              if (amt <= 0) {
                Get.snackbar('Validation', 'Enter amount');
                return;
              }
              await ctrl.addPayment(receivableId, amt, 'payment', noteCtrl.text);
              Navigator.of(context).pop(); // ✅ Always close dialog after success
            },
            child: Text('Add'),
          )
        ],
      ),
    );
  }

  void _showAdjustDialog(BuildContext context, String receivableId) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Adjust Amount', style: TextStyle(fontSize: 16.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  labelText: 'Adjustment (negative to reduce outstanding, د.إ)'),
            ),
            TextField(
              controller: noteCtrl,
              decoration: InputDecoration(labelText: 'Note (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              final amt = double.tryParse(amountCtrl.text) ?? 0;
              if (amt == 0) {
                Get.snackbar('Validation', 'Enter non-zero amount');
                return;
              }
              await ctrl.addPayment(receivableId, amt, 'adjustment', noteCtrl.text);
              Navigator.of(context).pop(); // ✅ Always close dialog after success
            },
            child: Text('Apply'),
          )
        ],
      ),
    );
  }
}
