import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_management_app/views/Authentication/login.dart';

class SignupController extends GetxController {
  var isLoading = false.obs;

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      isLoading.value = true;

      // Create user in Firebase Auth
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await userCred.user!.updateDisplayName(name);

      // Create user document in Firestore with "pending" status
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCred.user!.uid)
          .set({
        "name": name,
        "email": email,
        "phone": phone,
        "role": "user",
        "status": "pending", // ✅ User needs admin approval
        "allowedScreens": [], // Empty until admin approves
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Sign out the user immediately after registration
      await FirebaseAuth.instance.signOut();

      // Show success message
      Get.snackbar(
        "Registration Successful",
        "Your account is pending approval from the admin. You will be able to login once approved.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to login screen
      Get.offAll(() => LoginPage());
      
    } catch (e) {
      Get.snackbar(
        "Registration Failed",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}