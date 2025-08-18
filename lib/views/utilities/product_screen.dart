import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/Controller/product_controller.dart';

class ProductScreen extends StatelessWidget {
  final ProductController controller = Get.put(ProductController());
  final TextEditingController nameController = TextEditingController();
  String? selectedCategoryId;

  void openDialog({String? id, String? name, String? categoryId}) {
    nameController.text = name ?? '';
    selectedCategoryId = categoryId;

    Get.defaultDialog(
      title: id == null ? "Add Product" : "Edit Product",
      titleStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            SizedBox(height: 10.h),
            Obx(() {
              if (controller.categories.isEmpty) {
                return Text("No categories found",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]));
              }
              return DropdownButtonFormField<String>(
                value: selectedCategoryId != null &&
                        controller.categories.any(
                            (cat) => cat['id'] == selectedCategoryId)
                    ? selectedCategoryId
                    : null,
                hint: Text("Select Category", style: TextStyle(fontSize: 14.sp)),
                items: controller.categories
                    .map<DropdownMenuItem<String>>((category) {
                  return DropdownMenuItem<String>(
                    value: category['id'] as String,
                    child: Text(category['name'] ?? '',
                        style: TextStyle(fontSize: 14.sp)),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategoryId = value;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              );
            }),
          ],
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
          if (selectedCategoryId == null || nameController.text.isEmpty) {
            Get.snackbar("Error", "Please fill all fields");
            return;
          }
          if (id == null) {
            controller.addProduct(nameController.text, selectedCategoryId!);
          } else {
            controller.editProduct(id, nameController.text, selectedCategoryId!);
          }
          nameController.clear();
          selectedCategoryId = null;
          Get.back();
        },
        child: Text(id == null ? "Add" : "Update",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
      ),
      cancel: TextButton(
        onPressed: () {
          nameController.clear();
          selectedCategoryId = null;
          Get.back();
        },
        child: Text("Cancel", style: TextStyle(fontSize: 14.sp, color: Colors.red)),
      ),
    );
  }

  String getCategoryName(String? categoryId) {
    if (categoryId == null) return "Unknown";
    var category = controller.categories.firstWhereOrNull(
      (cat) => cat['id'] == categoryId,
    );
    return category != null ? (category['name'] ?? "Unknown") : "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (_, __) => Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text("Products",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.deepPurple,
          elevation: 2,
        ),
        body: Obx(() {
          if (controller.products.isEmpty) {
            return Center(
              child: Text(
                "No products found.",
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),
            );
          }
          return ListView.builder(
            itemCount: controller.products.length,
            padding: EdgeInsets.all(12.w),
            itemBuilder: (context, index) {
              var product = controller.products[index];
              return Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                margin: EdgeInsets.symmetric(vertical: 6.h),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  title: Text(
                    product['name'] ?? '',
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "Category: ${getCategoryName(product['categoryId'] as String?)}",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: Colors.deepPurple, size: 22.sp),
                        onPressed: () => openDialog(
                          id: product['id'] as String?,
                          name: product['name'] as String?,
                          categoryId: product['categoryId'] as String?,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: Colors.redAccent, size: 22.sp),
                        onPressed: () => controller
                            .deleteProduct(product['id'] as String),
                      ),
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
