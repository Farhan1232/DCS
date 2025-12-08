import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventory_management_app/views/Authentication/login.dart';

class PendingApprovalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(390, 844));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔹 Pending Icon with Animation
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.withOpacity(0.1),
                  ),
                  padding: EdgeInsets.all(40.w),
                  child: Icon(
                    Icons.hourglass_empty,
                    size: 100.sp,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 40.h),

                // 🔹 Title
                Text(
                  "Account Pending Approval",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),

                // 🔹 Message
                Text(
                  "Your account is awaiting approval from the admin. You will be notified once your account has been approved.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 40.h),

                // 🔹 Info Card
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 24.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          "Please wait for admin approval. This process may take some time.",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),

                // 🔹 Back to Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ).copyWith(
                      backgroundColor: MaterialStateProperty.all(null),
                      elevation: MaterialStateProperty.all(0),
                    ),
                    onPressed: () async {
                      // Sign out and go to login
                      await FirebaseAuth.instance.signOut();
                      Get.offAll(() => LoginPage());
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blueAccent, Colors.lightBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        child: Text(
                          "Back to Login",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}