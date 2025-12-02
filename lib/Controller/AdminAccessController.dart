import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAccessController extends GetxController {
  var selectedScreens = <String>[].obs;
  var selectedRole = "user".obs;

  void toggleScreen(String screen) {
    if (selectedScreens.contains(screen)) {
      selectedScreens.remove(screen);
    } else {
      selectedScreens.add(screen);
    }
  }

  Future<void> createUserWithAccess(String email, String password) async {
    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // For admin: full access, otherwise selectedScreens
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCred.user!.uid)
          .set({
        "email": email,
        "role": selectedRole.value,
        "allowedScreens": selectedRole.value == "admin"
            ? "all" // full access indicator
            : selectedScreens,
      });

      Get.snackbar("Success", "User created successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
