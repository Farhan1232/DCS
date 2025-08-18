import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class TransferController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var warehouses = <Map<String, dynamic>>[].obs;
  var products = <Map<String, dynamic>>[].obs;

  var selectedFromWarehouse = RxnString();
  var selectedToWarehouse = RxnString();
  var selectedProduct = RxnString();
  var quantity = 0.obs;

  @override
  void onInit() {
    fetchWarehouses();
    fetchProducts();
    super.onInit();
  }

  void fetchWarehouses() {
    _db.collection('warehouses').snapshots().listen((snapshot) {
      warehouses.value = snapshot.docs
          .map((doc) => {"id": doc.id, ...doc.data()})
          .toList();
    });
  }

  void fetchProducts() {
    _db.collection('products').snapshots().listen((snapshot) {
      products.value = snapshot.docs
          .map((doc) => {"id": doc.id, ...doc.data()})
          .toList();
    });
  }

  Future<void> transferStock() async {
    if (selectedFromWarehouse.value == null ||
        selectedToWarehouse.value == null ||
        selectedProduct.value == null ||
        quantity.value <= 0) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    final fromWarehouseName = warehouses
        .firstWhere((w) => w['id'] == selectedFromWarehouse.value)['name'];
    final toWarehouseName = warehouses
        .firstWhere((w) => w['id'] == selectedToWarehouse.value)['name'];
    final productName = products
        .firstWhere((p) => p['id'] == selectedProduct.value)['name'];

    await _db.collection('stock_transfers').add({
      "productId": selectedProduct.value,
      "productName": productName,
      "fromWarehouseId": selectedFromWarehouse.value,
      "fromWarehouseName": fromWarehouseName,
      "toWarehouseId": selectedToWarehouse.value,
      "toWarehouseName": toWarehouseName,
      "quantity": quantity.value,
      "date": FieldValue.serverTimestamp()
    });

    Get.snackbar("Success", "Stock transfer saved successfully");

    // Reset form
    selectedFromWarehouse.value = null;
    selectedToWarehouse.value = null;
    selectedProduct.value = null;
    quantity.value = 0;
  }
}
