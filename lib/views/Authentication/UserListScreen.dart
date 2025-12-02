import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserListScreen extends StatelessWidget {
  final List<String> screens = [
    "dashboard",
    "inventory",
    "cashbook",
    "receivable",
    "purchase_order"
  ];

  void _showUserDialog(BuildContext context, DocumentSnapshot userDoc) {
    String role = userDoc["role"];
    List selectedScreens = userDoc["allowedScreens"] is String
        ? [] // if "all" (admin), treat as full access
        : List<String>.from(userDoc["allowedScreens"] ?? []);

    var tempRole = role.obs;
    var tempScreens = selectedScreens.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Manage User",
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),

              // 🔹 Role Dropdown
              Obx(() => DropdownButtonFormField<String>(
                    value: tempRole.value,
                    items: ["user", "admin"].map((role) {
                      return DropdownMenuItem(
                          value: role, child: Text(role.capitalizeFirst ?? role));
                    }).toList(),
                    onChanged: (val) => tempRole.value = val!,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      labelText: "Role",
                    ),
                  )),
              SizedBox(height: 16.h),

              // 🔹 Screens (only if role is user)
              Obx(() => tempRole.value == "user"
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Allowed Screens",
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.w600)),
                        ...screens.map((s) => Obx(() => CheckboxListTile(
                              value: tempScreens.contains(s),
                              onChanged: (_) {
                                if (tempScreens.contains(s)) {
                                  tempScreens.remove(s);
                                } else {
                                  tempScreens.add(s);
                                }
                              },
                              title: Text(s.capitalizeFirst ?? s),
                              controlAffinity: ListTileControlAffinity.leading,
                            ))),
                      ],
                    )
                  : Container()),

              SizedBox(height: 20.h),

              // 🔹 Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
               // Delete Button
TextButton.icon(
  onPressed: () async {
    try {
      // 🔹 Delete user document from Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userDoc.id)
          .delete();

      // 🔹 Optional: mark in Firestore as deleted instead of actual Auth deletion
      // await FirebaseFirestore.instance
      //     .collection("users")
      //     .doc(userDoc.id)
      //     .update({'status': 'deleted'});

      Get.back();
      Get.snackbar("Deleted", "User removed successfully from Firestore");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  },
  icon: Icon(Icons.delete, color: Colors.red),
  label: Text("Delete",
      style: TextStyle(color: Colors.red, fontSize: 14.sp)),
),


                  // Save Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(userDoc.id)
                          .update({
                        "role": tempRole.value,
                        "allowedScreens": tempRole.value == "admin"
                            ? "all"
                            : tempScreens.toList(),
                      });
                      Get.back();
                      Get.snackbar("Updated", "User updated successfully");
                    },
                    icon: Icon(Icons.save, color: Colors.white),
                    label: Text("Save",
                        style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: Text(
          "Users List",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return Center(
              child: Text(
                "No users found.",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              String role = user["role"];
              List allowedScreens = user["allowedScreens"] ?? [];

              return Card(
                elevation: 3,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                margin: EdgeInsets.symmetric(vertical: 8.h),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    children: [
                      // 🔹 Avatar
                      CircleAvatar(
                        radius: 28.r,
                        backgroundColor: role == "admin"
                            ? Colors.deepPurple.withOpacity(0.15)
                            : Colors.blue.withOpacity(0.15),
                        child: Icon(
                          role == "admin" ? Icons.admin_panel_settings : Icons.person,
                          color: role == "admin" ? Colors.deepPurple : Colors.blue,
                          size: 26.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // 🔹 Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user["email"],
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            SizedBox(height: 6.h),
                            Text("Role: ${role.capitalizeFirst}",
                                style: TextStyle(fontSize: 13.sp, color: Colors.grey[700])),
                            Text(
                                "Screens: ${allowedScreens is String ? "All" : (allowedScreens.isNotEmpty ? allowedScreens.join(", ") : "None")}",
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                          ],
                        ),
                      ),

                      // 🔹 3-dot menu
                      IconButton(
                        icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                        onPressed: () => _showUserDialog(context, user),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
