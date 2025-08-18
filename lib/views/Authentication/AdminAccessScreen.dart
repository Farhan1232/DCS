import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/Controller/AdminAccessController.dart';
import 'package:inventory_management_app/views/Authentication/UserListScreen.dart';

class AdminAccessScreen extends StatelessWidget {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final ctrl = Get.put(AdminAccessController());

  final screens = ["dashboard", "inventory", "cashbook", "receivable", "purchase_order",];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: Text("Admin Access Control",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.group, color: Colors.white),
            onPressed: () => Get.to(() => UserListScreen()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Section Card for Role
            _buildSectionCard(
              title: "Select Role",
              icon: Icons.admin_panel_settings,
              child: Obx(() => DropdownButtonFormField<String>(
                    value: ctrl.selectedRole.value,
                    items: ["user", "admin"].map((role) {
                      return DropdownMenuItem(
                          value: role, child: Text(role.capitalizeFirst ?? role));
                    }).toList(),
                    onChanged: (val) => ctrl.selectedRole.value = val!,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                  )),
            ),

            SizedBox(height: 16.h),

            // 🔹 Section Card for Credentials
            _buildSectionCard(
              title: "Account Details",
              icon: Icons.person,
              child: Column(
                children: [
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // 🔹 Section Card for Screens
            _buildSectionCard(
              title: "Screens Access",
              icon: Icons.dashboard,
              child: Obx(() => Column(
                    children: screens.map((s) {
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        margin: EdgeInsets.symmetric(vertical: 5.h),
                        child: CheckboxListTile(
                          title: Text(s.capitalizeFirst ?? s,
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                          value: ctrl.selectedScreens.contains(s),
                          onChanged: (_) => ctrl.toggleScreen(s),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.deepPurple,
                        ),
                      );
                    }).toList(),
                  )),
            ),

            SizedBox(height: 30.h),

            // 🔹 Save Button
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  elevation: 5,
                  shadowColor: Colors.deepPurpleAccent,
                  textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                icon: Icon(Icons.save, size: 22.sp),
                label: Text("Save Access"),
                onPressed: () {
                  ctrl.createUserWithAccess(
                    emailCtrl.text.trim(),
                    passCtrl.text.trim(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Reusable Section Card
  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 3,
      shadowColor: Colors.black12,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple.withOpacity(0.1),
                  child: Icon(icon, color: Colors.deepPurple),
                ),
                SizedBox(width: 10.w),
                Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(height: 12.h),
            child,
          ],
        ),
      ),
    );
  }
}
