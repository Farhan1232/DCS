import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/Controller/signup_controller.dart';


class SignupPage extends StatelessWidget {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  final signupCtrl = Get.put(SignupController());

  // ✅ Reactive state for password visibility
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(390, 844));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 App Logo
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: EdgeInsets.all(20.w),
                  child: Icon(Icons.person_add, size: 70.sp, color: Colors.white),
                ),
                SizedBox(height: 25.h),

                // 🔹 Title
                Text("Create Account",
                    style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                SizedBox(height: 8.h),
                Text("Sign up to get started",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                SizedBox(height: 40.h),

                // 🔹 Name Field
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
                    controller: nameCtrl,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: Icon(Icons.person, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

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
                      prefixIcon: Icon(Icons.email, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // 🔹 Phone Field
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
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      prefixIcon: Icon(Icons.phone, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // 🔹 Password Field with Hide/Show
                Obx(() => Container(
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
                        controller: passCtrl,
                        obscureText: isPasswordHidden.value,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock, color: Colors.blue),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              isPasswordHidden.value = !isPasswordHidden.value;
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    )),
                SizedBox(height: 20.h),

                // 🔹 Confirm Password Field with Hide/Show
                Obx(() => Container(
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
                        controller: confirmPassCtrl,
                        obscureText: isConfirmPasswordHidden.value,
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.blue),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isConfirmPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              isConfirmPasswordHidden.value =
                                  !isConfirmPasswordHidden.value;
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    )),
                SizedBox(height: 35.h),

                // 🔹 Signup Button
                Obx(() => signupCtrl.isLoading.value
                    ? CircularProgressIndicator(color: Colors.blue)
                    : SizedBox(
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
                          onPressed: () {
                            // ✅ Validation
                            if (nameCtrl.text.trim().isEmpty) {
                              Get.snackbar("Error", "Please enter your name");
                              return;
                            }
                            if (emailCtrl.text.trim().isEmpty) {
                              Get.snackbar("Error", "Please enter your email");
                              return;
                            }
                            if (phoneCtrl.text.trim().isEmpty) {
                              Get.snackbar("Error", "Please enter your phone number");
                              return;
                            }
                            if (passCtrl.text.trim().length < 6) {
                              Get.snackbar("Error", "Password must be at least 6 characters");
                              return;
                            }
                            if (passCtrl.text.trim() != confirmPassCtrl.text.trim()) {
                              Get.snackbar("Error", "Passwords do not match");
                              return;
                            }

                            // ✅ Call signup
                            signupCtrl.signup(
                              name: nameCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              password: passCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                            );
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
                              child: Text("Sign Up",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                      )),
                SizedBox(height: 20.h),

                // 🔹 Already have an account? Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back(); // Navigate back to login
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}