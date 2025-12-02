import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransferHistoryScreen extends StatelessWidget {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (_, __) => Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            "Transfer History",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          elevation: 2,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _db
              .collection('stock_transfers')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final transfers = snapshot.data!.docs;

            if (transfers.isEmpty) {
              return Center(
                child: Text(
                  "No transfer history found",
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(12.w),
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                final data =
                    transfers[index].data() as Map<String, dynamic>;

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 6.h),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${data['productName']} - ${data['quantity']}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "From: ${data['fromWarehouseName']} → To: ${data['toWarehouseName']}",
                          style: TextStyle(
                              fontSize: 14.sp, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Date: ${(data['date'] as Timestamp).toDate()}",
                          style: TextStyle(
                              fontSize: 13.sp, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
