import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory_management_app/Controller/warehouse_controller.dart';

class WarehouseScreen extends StatelessWidget {
  final WarehouseController controller = Get.put(WarehouseController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  void openDialog({String? id, String? name, String? location}) {
    if (name != null) nameController.text = name;
    if (location != null) locationController.text = location;

    Get.defaultDialog(
      title: id == null ? "Add Warehouse" : "Edit Warehouse",
      titleStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Warehouse Name",
                labelStyle: TextStyle(fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: "Location",
                labelStyle: TextStyle(fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        ),
        onPressed: () {
          if (id == null) {
            controller.addWarehouse(
                nameController.text, locationController.text);
          } else {
            controller.editWarehouse(
                id, nameController.text, locationController.text);
          }
          nameController.clear();
          locationController.clear();
          Get.back();
        },
        child: Text(
          id == null ? "Add" : "Update",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
      ),
      cancel: TextButton(
        onPressed: () {
          nameController.clear();
          locationController.clear();
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
            "Warehouse",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          elevation: 3,
        ),
        body: Obx(() {
          if (controller.warehouses.isEmpty) {
            return Center(
              child: Text(
                "No warehouses found.",
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              ),
            );
          }
          return ListView.builder(
            itemCount: controller.warehouses.length,
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            itemBuilder: (context, index) {
              var warehouse = controller.warehouses[index];
              return Card(
                color: Colors.white,
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  title: Text(
                    warehouse['name'],
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    warehouse['location'],
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: Colors.blue, size: 22.sp),
                        onPressed: () => openDialog(
                          id: warehouse['id'],
                          name: warehouse['name'],
                          location: warehouse['location'],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: Colors.red, size: 22.sp),
                        onPressed: () =>
                            controller.deleteWarehouse(warehouse['id']),
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
          child: Icon(Icons.add, size: 24.sp, color: Colors.white),
        ),
      ),
    );
  }
}
