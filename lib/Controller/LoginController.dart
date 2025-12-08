import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_management_app/views/Authentication/login.dart';
import 'package:inventory_management_app/views/Authentication/pending_screen.dart';

import 'package:inventory_management_app/views/bottomNavBar/MainScreen.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkIfUserLoggedIn();
  }

  // ✅ Check if user is already logged in
  void _checkIfUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is already logged in, fetch role and allowed screens
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // ✅ Check if user is approved
        String status = userDoc["status"] ?? "pending";
        
        if (status == "pending") {
          // Navigate to pending approval screen
          Get.offAll(() => PendingApprovalScreen());
          return;
        }

        String role = userDoc["role"] ?? "user";
        List<String> allowedScreens = role == "admin"
            ? ["dashboard","inventory","cashbook","receivable","purchase_order"]
            : List<String>.from(userDoc["allowedScreens"] ?? []);

        // Navigate to main screen
        Get.offAll(() => MainScreen(
            allowedScreens: allowedScreens,
            role: role,
            initialIndex: 0,
        ));
      }
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userCred.user!.uid)
          .get();

      if (userDoc.exists) {
        // ✅ Check if user status is approved
        String status = userDoc["status"] ?? "pending";
        
        if (status == "pending") {
          // Navigate to pending approval screen
          Get.offAll(() => PendingApprovalScreen());
          return;
        }

        if (status == "rejected") {
          // Sign out the user
          await FirebaseAuth.instance.signOut();
          Get.snackbar(
            "Account Rejected",
            "Your account has been rejected by admin. Please contact support.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        String role = userDoc["role"] ?? "user";

        List<String> allowedScreens = role == "admin"
            ? ["dashboard","inventory","cashbook","receivable","purchase_order"]
            : List<String>.from(userDoc["allowedScreens"] ?? []);

        Get.offAll(() => MainScreen(
            allowedScreens: allowedScreens,
            role: role,
            initialIndex: 0,
        ));
      } else {
        Get.snackbar("Error", "No access defined for this user");
      }
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Logout logic
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Directly navigate to login screen widget
      Get.offAll(() => LoginPage());
    } catch (e) {
      Get.snackbar("Logout Failed", e.toString());
    }
  }
}