import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/Controller/category_controller.dart';

class CategoryScreen extends StatelessWidget {
  final CategoryController controller = Get.put(CategoryController());
  final TextEditingController nameController = TextEditingController();

  void openDialog({String? id, String? name}) {
    if (name != null) nameController.text = name;

    Get.defaultDialog(
      title: id == null ? "Add Category" : "Edit Category",
      titleStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: "Category Name",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        ),
        onPressed: () {
          if (id == null) {
            controller.addCategory(nameController.text);
          } else {
            controller.editCategory(id, nameController.text);
          }
          nameController.clear();
          Get.back();
        },
        child: Text(
          id == null ? "Add" : "Update",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ),
      cancel: TextButton(
        onPressed: () {
          nameController.clear();
          Get.back();
        },
        child: Text(
          "Cancel",
          style: TextStyle(fontSize: 14.sp, color: Colors.red),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (_, __) => Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            "Categories",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.deepPurple,
          elevation: 2,
        ),
        body: Obx(() {
          if (controller.categories.isEmpty) {
            return Center(
              child: Text(
                "No categories found.",
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),
            );
          }
          return ListView.builder(
            itemCount: controller.categories.length,
            padding: EdgeInsets.all(12.w),
            itemBuilder: (context, index) {
              var category = controller.categories[index];
              return Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                margin: EdgeInsets.symmetric(vertical: 6.h),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 8.h),
                  title: Text(
                    category['name'],
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Icon(Icons.edit,
                              color: Colors.deepPurple, size: 22.sp),
                          onPressed: () => openDialog(
                              id: category['id'], name: category['name'])),
                      IconButton(
                          icon: Icon(Icons.delete,
                              color: Colors.redAccent, size: 22.sp),
                          onPressed: () =>
                              controller.deleteCategory(category['id'])),
                    ],
                  ),
                ),
              );
            },
          );
        }),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          onPressed: () => openDialog(),
          child: Icon(Icons.add, size: 26.sp, color: Colors.white),
        ),
      ),
    );
  }
}
