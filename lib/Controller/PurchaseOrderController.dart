// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class PurchaseOrderController extends GetxController {
//   // Selected warehouse + ETA
//   var selectedWarehouseId = RxnString();
//   var eta = Rxn<DateTime>();

//   // Dropdown lists
//   var products = [].obs;
//   var warehouses = [].obs;

//   // Product form entries for PO
//   var productEntries = <Map<String, dynamic>>[].obs;

//   // Purchase Orders List
//   var purchaseOrders = [].obs;

//   @override
//   void onInit() {
//     fetchProducts();
//     fetchWarehouses();
//     fetchPurchaseOrders();
//     super.onInit();
//   }

//   void fetchProducts() {
//     FirebaseFirestore.instance
//         .collection('products')
//         .snapshots()
//         .listen((snapshot) {
//       products.value = snapshot.docs
//           .map((doc) => {
//                 'id': doc.id,
//                 'name': doc['name'],
//               })
//           .toList();
//     });
//   }

//   void fetchWarehouses() {
//     FirebaseFirestore.instance
//         .collection('warehouses')
//         .snapshots()
//         .listen((snapshot) {
//       warehouses.value = snapshot.docs
//           .map((doc) => {
//                 'id': doc.id,
//                 'name': doc['name'],
//               })
//           .toList();
//     });
//   }

//   void fetchPurchaseOrders() {
//     FirebaseFirestore.instance
//         .collection('purchase_orders')
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .listen((snapshot) {
//       purchaseOrders.value = snapshot.docs.map((doc) => {
//             'id': doc.id,
//             ...doc.data(),
//           }).toList();
//     });
//   }

//   /// Add new product entry (for UI form)
//   void addProductEntry() {
//     productEntries.add({
//       'productId': null,
//       'qtyController': TextEditingController(),
//       'priceController': TextEditingController(),
//     });
//   }

//   /// Remove product entry
//   void removeProductEntry(int index) {
//     productEntries.removeAt(index);
//   }

//   /// Save PO
//   Future<void> createPurchaseOrder() async {
//     if (selectedWarehouseId.value == null ||
//         eta.value == null ||
//         productEntries.isEmpty) {
//       Get.snackbar("Error", "Please select warehouse, ETA and add products");
//       return;
//     }

//     var warehouseName = warehouses
//         .firstWhere((w) => w['id'] == selectedWarehouseId.value)['name'];

//     // Build items list
//     var items = productEntries.map((entry) {
//       var productName = products
//           .firstWhere((p) => p['id'] == entry['productId'])['name'];
//       return {
//         'productId': entry['productId'],
//         'productName': productName,
//         'qty': int.tryParse(entry['qtyController'].text) ?? 0,
//         'price': double.tryParse(entry['priceController'].text) ?? 0.0,
//         'receivedQty': 0,
//       };
//     }).toList();

//     await FirebaseFirestore.instance.collection('purchase_orders').add({
//       'warehouseId': selectedWarehouseId.value,
//       'warehouseName': warehouseName,
//       'eta': eta.value!.toIso8601String(),
//       'status': 'Pending',
//       'items': items,
//       'createdBy': 'Admin',
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     // Clear form
//     productEntries.clear();
//     selectedWarehouseId.value = null;
//     eta.value = null;

//     Get.snackbar("Success", "Purchase Order Created");
//   }

// Future<void> markAsReceived(String poId, Map<String, dynamic> poData,
//     Map<String, int> receivedItems) async {
//   List items = poData['items'] ?? [];
//   bool allReceived = true;

//   // 🔹 Update purchase order items
//   List updatedItems = items.map((item) {
//     int receivedQty =
//         (item['receivedQty'] ?? 0) + (receivedItems[item['productId']] ?? 0);
//     if (receivedQty < item['qty']) allReceived = false;
//     return {
//       ...item,
//       'receivedQty': receivedQty,
//     };
//   }).toList();

//   String newStatus = allReceived ? "Received" : "Partially Received";

//   // 🔹 Update PO status in Firestore
//   await FirebaseFirestore.instance
//       .collection('purchase_orders')
//       .doc(poId)
//       .update({
//     'items': updatedItems,
//     'status': newStatus,
//     'confirmedBy': 'Admin',
//     'confirmedAt': FieldValue.serverTimestamp(),
//   });

//   // 🔹 Update or create stock_in records
//   for (var entry in receivedItems.entries) {
//     var productId = entry.key;
//     var qty = entry.value;
//     var product = items.firstWhere((e) => e['productId'] == productId);

//     var stockInRef = FirebaseFirestore.instance.collection('stock_in');

//     // Search if stock_in already exists for this product + warehouse
//     var existing = await stockInRef
//         .where('productId', isEqualTo: productId)
//         .where('warehouseId', isEqualTo: poData['warehouseId'])
//         .limit(1)
//         .get();

//     if (existing.docs.isNotEmpty) {
//       // 🔹 If exists → update qty (add to existing)
//       var docId = existing.docs.first.id;
//       var currentQty = existing.docs.first['qty'] ?? 0;

//       await stockInRef.doc(docId).update({
//         'qty': currentQty + qty,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } else {
//       // 🔹 If not exists → create new doc
//       await stockInRef.add({
//         'productId': productId,
//         'productName': product['productName'],
//         'qty': qty,
//         'price': product['price'],
//         'warehouseId': poData['warehouseId'],
//         'warehouseName': poData['warehouseName'],
//         'date': FieldValue.serverTimestamp(),
//         'createdBy': 'Admin',
//       });
//     }
//   }

//   Get.snackbar("Updated", "Stock In updated and PO updated");
// }

// }








import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseOrderController extends GetxController {
  // Selected warehouse + ETA
  var selectedWarehouseId = RxnString();
  var eta = Rxn<DateTime>();

  // Dropdown lists
  var products = [].obs;
  var warehouses = [].obs;

  // Product form entries for PO
  var productEntries = <Map<String, dynamic>>[].obs;

  // Purchase Orders List
  var purchaseOrders = [].obs;

  @override
  void onInit() {
    fetchProducts();
    fetchWarehouses();
    fetchPurchaseOrders();
    super.onInit();
  }

  void fetchProducts() {
    FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .listen((snapshot) {
      products.value = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
              })
          .toList();
    });
  }

  void fetchWarehouses() {
    FirebaseFirestore.instance
        .collection('warehouses')
        .snapshots()
        .listen((snapshot) {
      warehouses.value = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
              })
          .toList();
    });
  }

  void fetchPurchaseOrders() {
    FirebaseFirestore.instance
        .collection('purchase_orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      purchaseOrders.value = snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data(),
          }).toList();
    });
  }

  /// Add new product entry (for UI form)
  void addProductEntry() {
    productEntries.add({
      'productId': null,
      'qtyController': TextEditingController(),
      'priceController': TextEditingController(),
    });
  }

  /// Remove product entry
  void removeProductEntry(int index) {
    productEntries.removeAt(index);
  }

  /// Save PO
  Future<void> createPurchaseOrder() async {
    if (selectedWarehouseId.value == null ||
        eta.value == null ||
        productEntries.isEmpty) {
      Get.snackbar("Error", "Please select warehouse, ETA and add products");
      return;
    }

    var warehouseName = warehouses
        .firstWhere((w) => w['id'] == selectedWarehouseId.value)['name'];

    // Build items list
    var items = productEntries.map((entry) {
      var productName = products
          .firstWhere((p) => p['id'] == entry['productId'])['name'];
      return {
        'productId': entry['productId'],
        'productName': productName,
        'qty': int.tryParse(entry['qtyController'].text) ?? 0,
        'price': double.tryParse(entry['priceController'].text) ?? 0.0,
        'receivedQty': 0,
      };
    }).toList();

    await FirebaseFirestore.instance.collection('purchase_orders').add({
      'warehouseId': selectedWarehouseId.value,
      'warehouseName': warehouseName,
      'eta': eta.value!.toIso8601String(),
      'status': 'Pending',
      'items': items,
      'createdBy': 'Admin',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Clear form
    productEntries.clear();
    selectedWarehouseId.value = null;
    eta.value = null;

    Get.snackbar("Success", "Purchase Order Created");
  }

  /// Mark Purchase Order as Received (without stock_in)
  Future<void> markAsReceived(String poId, Map<String, dynamic> poData,
      Map<String, int> receivedItems) async {
    List items = poData['items'] ?? [];
    bool allReceived = true;

    // 🔹 Update purchase order items
    List updatedItems = items.map((item) {
      int receivedQty =
          (item['receivedQty'] ?? 0) + (receivedItems[item['productId']] ?? 0);
      if (receivedQty < item['qty']) allReceived = false;
      return {
        ...item,
        'receivedQty': receivedQty,
      };
    }).toList();

    String newStatus = allReceived ? "Received" : "Partially Received";

    // 🔹 Update PO status in Firestore
    await FirebaseFirestore.instance
        .collection('purchase_orders')
        .doc(poId)
        .update({
      'items': updatedItems,
      'status': newStatus,
      'confirmedBy': 'Admin',
      'confirmedAt': FieldValue.serverTimestamp(),
    });

    Get.snackbar("Updated", "Purchase Order updated successfully");
  }
}
