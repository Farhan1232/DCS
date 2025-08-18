import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inventory_management_app/Controller/receivable_controller.dart';
import 'package:inventory_management_app/Controller/stock_controller.dart';
import 'package:inventory_management_app/firebase_options.dart';
import 'package:inventory_management_app/services/firestore_service.dart';
import 'package:inventory_management_app/services/local_storage.dart';
import 'package:inventory_management_app/views/Authentication/login.dart';
import 'package:inventory_management_app/views/bottomNavBar/MainScreen.dart';





void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register services
  Get.put(FirestoreService());
  Get.put(LocalUserService());
  Get.put(StockController()); // 👈 Register here
  

  // Register controllers that should live globally
  Get.put(ReceivableController());


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Base design size (width, height)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'IMS App',
          debugShowCheckedModeBanner: false,
          home: LoginPage(),
        );
      },
    );
  }
}

