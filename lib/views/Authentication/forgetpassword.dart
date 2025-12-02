import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(390, 844));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: Text("Forgot Password",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Icon / Illustration
                Icon(Icons.lock_reset, size: 80.sp, color: Colors.deepPurple),
                SizedBox(height: 20.h),

                Text("Reset Your Password",
                    style: TextStyle(
                        fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 8.h),
                Text(
                  "Enter your registered email and we’ll send you a reset link.",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h),

                // 🔹 Email Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 30.h),

                // 🔹 Reset Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      backgroundColor: Colors.deepPurple,
                    ),
                    onPressed: () async {
                      if (emailCtrl.text.trim().isEmpty) {
                        Get.snackbar("Error", "Please enter your email");
                        return;
                      }
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: emailCtrl.text.trim(),
                        );
                        Get.snackbar("Success",
                            "Password reset email sent! Check your inbox.");
                      } catch (e) {
                        Get.snackbar("Error", e.toString());
                      }
                    },
                    child: Text("Send Reset Link",
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
                SizedBox(height: 20.h),

                // 🔹 Back to Login
                TextButton(
                  onPressed: () {
                    Get.back(); // ✅ Go back to LoginPage
                  },
                  child: Text("Back to Login",
                      style: TextStyle(fontSize: 14.sp, color: Colors.deepPurple)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
