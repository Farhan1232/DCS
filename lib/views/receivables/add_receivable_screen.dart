import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory_management_app/Controller/receivable_controller.dart';
import 'package:inventory_management_app/views/receivables/receivables_dashboard_screen.dart';

class AddReceivableScreen extends StatefulWidget {
  @override
  State<AddReceivableScreen> createState() => _AddReceivableScreenState();
}

class _AddReceivableScreenState extends State<AddReceivableScreen> {
  final ReceivableController ctrl = Get.find<ReceivableController>();
  final _form = GlobalKey<FormState>();

  String customerName = '';
  double amount = 0;
  DateTime? dueDate;
  String refNo = '';
  String notes = '';

  void pickDueDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (selected != null) setState(() => dueDate = selected);
  }

  void save() async {
  if (!_form.currentState!.validate()) return;
  if (dueDate == null) {
    Get.snackbar('Validation', 'Select due date',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white);
    return;
  }
  _form.currentState!.save();
  await ctrl.createReceivable(
    customerName: customerName,
    totalAmount: amount,
    dueDate: dueDate!,
    refNo: refNo,
    notes: notes,
  );

  // 👇 Navigate directly to ReceivablesDashboardScreen
  Get.off(() => ReceivablesDashboardScreen());
}


  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (_, __) => Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            'Add Receivable',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.blueAccent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Name
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Customer Name',
                        labelStyle: TextStyle(fontSize: 14.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                      onSaved: (v) => customerName = v!.trim(),
                    ),
                    SizedBox(height: 12.h),

                    // Amount
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        labelStyle: TextStyle(fontSize: 14.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                      onSaved: (v) =>
                          amount = double.tryParse(v ?? '0') ?? 0,
                    ),
                    SizedBox(height: 12.h),

                    // Due Date
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 14.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey),
                              color: Colors.white,
                            ),
                            child: Text(
                              dueDate == null
                                  ? 'Select due date'
                                  : dueDate!.toLocal().toString().split(' ')[0],
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          onPressed: pickDueDate,
                          child: Text('Pick Date',
                              style: TextStyle(fontSize: 14.sp)),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Ref No
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Ref No (optional)',
                        labelStyle: TextStyle(fontSize: 14.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onSaved: (v) => refNo = v ?? '',
                    ),
                    SizedBox(height: 12.h),

                    // Notes
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Notes (optional)',
                        labelStyle: TextStyle(fontSize: 14.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onSaved: (v) => notes = v ?? '',
                    ),
                    SizedBox(height: 16.h),

                    // Save Button
                    Center(
                      child: Obx(() => ctrl.loading.value
                          ? CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              height: 48.h,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                onPressed: save,
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
