import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Core data
  var products = [].obs;
  var warehouses = [].obs;
  var inventory = [].obs;
  var categories = [].obs;

  // Temp Stock In list (UI buffer)
  var stockInItems = <Map<String, dynamic>>[].obs;

  // Stock Out history
  var stockOutHistory = [].obs;

  // Selected dropdown persistence
  var selectedProductId = RxnString();
  var selectedWarehouseId = RxnString();

  bool _sanitizersStarted = false;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchWarehouses();
    fetchCategories();
    fetchInventory();
    fetchStockOutHistory();
    _startSanitizers(); // watch and fix bad docs continuously
  }

  // ------------------------
  // Master data fetch
  // ------------------------

  void fetchCategories() {
    _db.collection('categories').snapshots().listen((snapshot) {
      categories.value =
          snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    });
  }

  void fetchProducts() {
    _db.collection('products').snapshots().listen((snapshot) {
      products.value =
          snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    });
  }

  void fetchWarehouses() {
    _db.collection('warehouses').snapshots().listen((snapshot) {
      warehouses.value =
          snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    });
  }

  // ------------------------
  // Stock In / Stock Out
  // ------------------------

  /// Add or update Stock In (docId = productId-warehouseId)
  Future<void> addStockIn(
    String productId,
    String warehouseId,
    double costPrice,
    int quantity,
    String? note,
  ) async {
    final docId = "${productId}_$warehouseId"; // ✅ fixed docId
    final ref = _db.collection('stock_in').doc(docId);

    final snap = await ref.get();
    if (snap.exists) {
      final prevQty = snap['quantity'] as int? ?? 0;
      await ref.update({
        'quantity': prevQty + quantity,
        'costPrice': costPrice,
        'note': note ?? "",
        'date': DateTime.now(),
      });
    } else {
      await ref.set({
        'productId': productId,
        'warehouseId': warehouseId,
        'costPrice': costPrice,
        'quantity': quantity,
        'note': note ?? "",
        'date': DateTime.now(),
      });
    }
  }

  /// Add or update Stock Out (docId = productId-warehouseId)
  Future<void> addStockOut(
    String productId,
    String warehouseId,
    int quantity,
  ) async {
    final docId = "${productId}_$warehouseId"; // ✅ fixed docId
    final ref = _db.collection('stock_out').doc(docId);

    final snap = await ref.get();
    if (snap.exists) {
      final prevQty = snap['quantity'] as int? ?? 0;
      await ref.update({
        'quantity': prevQty + quantity,
        'date': DateTime.now(),
      });
    } else {
      await ref.set({
        'productId': productId,
        'warehouseId': warehouseId,
        'quantity': quantity,
        'date': DateTime.now(),
      });
    }
  }

  void fetchStockOutHistory() {
    _db
        .collection('stock_out')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      stockOutHistory.value = snapshot.docs.map((doc) {
        return {
          'productId': doc['productId'],
          'warehouseId': doc['warehouseId'],
          'quantity': doc['quantity'],
          'date': (doc['date'] as Timestamp).toDate(),
        };
      }).toList();
    });
  }

  // ------------------------
  // Temp stock in list
  // ------------------------

  void addStockInItem(Map<String, dynamic> item) => stockInItems.add(item);
  void removeStockInItem(int index) => stockInItems.removeAt(index);
  void clearStockInItems() => stockInItems.clear();

  Future<void> saveAllStockIn() async {
    if (stockInItems.isEmpty) {
      Get.snackbar("Error", "No stock items to save");
      return;
    }

    for (var item in stockInItems) {
      final productId = item['productId'];
      final warehouseId = item['warehouseId'];
      final costPrice = (item['costPrice'] as num).toDouble();
      final quantity = item['quantity'] as int;
      final note = item['note'] ?? "";

      final docId = "${productId}_$warehouseId"; // ✅ fixed docId
      final ref = _db.collection('stock_in').doc(docId);

      final snap = await ref.get();
      if (snap.exists) {
        final prevQty = snap['quantity'] as int? ?? 0;
        await ref.update({
          'quantity': prevQty + quantity,
          'costPrice': costPrice,
          'note': note,
          'date': DateTime.now(),
        });
      } else {
        await ref.set({
          'productId': productId,
          'warehouseId': warehouseId,
          'costPrice': costPrice,
          'quantity': quantity,
          'note': note,
          'date': DateTime.now(),
        });
      }
    }

    clearStockInItems();
    fetchInventory();
    Get.snackbar("Success", "Stock saved successfully");
  }

  // ------------------------
  // Quantity helper
  // ------------------------

  Future<int> getAvailableQuantity(
      String productId, String warehouseId) async {
    final inSnap =
        await _db.collection('stock_in').doc("${productId}_$warehouseId").get();
    final outSnap =
        await _db.collection('stock_out').doc("${productId}_$warehouseId").get();

    final totalIn = inSnap.exists ? (inSnap['quantity'] as int) : 0;
    final totalOut = outSnap.exists ? (outSnap['quantity'] as int) : 0;

    return totalIn - totalOut;
  }

  // ------------------------
  // Inventory (same logic, faster now)
  // ------------------------

  void fetchInventory() {
    RxList stockInDocs = [].obs;
    RxList stockOutDocs = [].obs;

    _db.collection('stock_in').snapshots().listen((snap) {
      stockInDocs.value =
          snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      _recomputeInventory(stockInDocs, stockOutDocs);
    });

    _db.collection('stock_out').snapshots().listen((snap) {
      stockOutDocs.value =
          snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      _recomputeInventory(stockInDocs, stockOutDocs);
    });
  }

  void _recomputeInventory(List stockInDocs, List stockOutDocs) {
    if (products.isEmpty || warehouses.isEmpty) return;

    final Map<String, int> stockInMap = {};
    final Map<String, double> latestPriceMap = {};
    final Map<String, int> stockOutMap = {};

    for (final doc in stockInDocs) {
      final pid = doc['productId'];
      final wid = doc['warehouseId'];
      final key = "$pid-$wid";

      stockInMap[key] = (stockInMap[key] ?? 0) + (doc['quantity'] as int);
      latestPriceMap[key] = (doc['costPrice'] as num).toDouble();
    }

    for (final doc in stockOutDocs) {
      final pid = doc['productId'];
      final wid = doc['warehouseId'];
      final key = "$pid-$wid";

      stockOutMap[key] = (stockOutMap[key] ?? 0) + (doc['quantity'] as int);
    }

    final List<Map<String, dynamic>> inventoryList = [];

    for (final product in products) {
      for (final warehouse in warehouses) {
        final key = "${product['id']}-${warehouse['id']}";
        final totalIn = stockInMap[key] ?? 0;
        final totalOut = stockOutMap[key] ?? 0;
        final availableQty = totalIn - totalOut;

        if (availableQty > 0) {
          inventoryList.add({
            'productId': product['id'],
            'productName': product['name'],
            'warehouseId': warehouse['id'],
            'warehouseName': warehouse['name'],
            'quantity': availableQty,
            'price': latestPriceMap[key] ?? 0,
            'categoryId': product['categoryId'],
          });
        }
      }
    }

    inventory.value = inventoryList;
  }

  // ------------------------
  // Sanitizer (kept same)
  // ------------------------

  void _startSanitizers() {
    if (_sanitizersStarted) return;
    _sanitizersStarted = true;

    _db.collection('stock_in').snapshots().listen((snap) {
      _sanitizeDocs(snap.docs, 'stock_in');
    });

    _db.collection('stock_out').snapshots().listen((snap) {
      _sanitizeDocs(snap.docs, 'stock_out');
    });
  }

  Future<void> _sanitizeDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String collectionName,
  ) async {
    if (products.isEmpty || warehouses.isEmpty) return;

    final Map<String, String> productNameToId = {
      for (final p in products)
        (p['name']?.toString().trim().toLowerCase() ?? ''): p['id']
    };
    final Map<String, String> warehouseNameToId = {
      for (final w in warehouses)
        (w['name']?.toString().trim().toLowerCase() ?? ''): w['id']
    };

    WriteBatch batch = _db.batch();
    int pending = 0;

    for (final d in docs) {
      final data = d.data();

      final hasPN = data.containsKey('productName');
      final hasWN = data.containsKey('warehouseName');
      final hasPI = data.containsKey('productId');
      final hasWI = data.containsKey('warehouseId');

      Map<String, dynamic> upd = {};

      if (!hasPI && hasPN) {
        final pn = data['productName']?.toString().trim().toLowerCase() ?? '';
        final pid = productNameToId[pn];
        if (pid != null && pid.isNotEmpty) {
          upd['productId'] = pid;
        }
      }
      if (!hasWI && hasWN) {
        final wn =
            data['warehouseName']?.toString().trim().toLowerCase() ?? '';
        final wid = warehouseNameToId[wn];
        if (wid != null && wid.isNotEmpty) {
          upd['warehouseId'] = wid;
        }
      }

      final willHavePI = upd.containsKey('productId') || hasPI;
      final willHaveWI = upd.containsKey('warehouseId') || hasWI;

      if (hasPN && willHavePI) {
        upd['productName'] = FieldValue.delete();
      }
      if (hasWN && willHaveWI) {
        upd['warehouseName'] = FieldValue.delete();
      }

      if (upd.isNotEmpty) {
        batch.update(d.reference, upd);
        pending++;
        if (pending >= 400) {
          await batch.commit();
          batch = _db.batch();
          pending = 0;
        }
      }
    }

    if (pending > 0) await batch.commit();
  }
  /// Always create a *log entry* but also update the aggregated stock_in doc
/// Doc ID stays fixed as productId_warehouseId for instant inventory updates.
/// UI that previously called addStockInSeparate will keep working.
Future<void> addStockInSeparate(
  String productId,
  String warehouseId,
  double costPrice,
  int quantity,
  String? note,
) async {
  // 1) Write a log row (optional history). Uses auto ID; safe & fast.
  // If you don't need history, you can delete this block.
  await _db.collection('stock_in_logs').add({
    'productId': productId,
    'warehouseId': warehouseId,
    'costPrice': costPrice,
    'quantity': quantity,
    'note': note ?? "",
    'date': DateTime.now(),
  });

  // 2) Update the aggregated stock_in doc with fixed ID (fast real-time)
  final docId = "${productId}_$warehouseId";
  final ref = _db.collection('stock_in').doc(docId);
  final snap = await ref.get();

  if (snap.exists) {
    final prevQty = (snap.data()?['quantity'] as int?) ?? 0;
    await ref.update({
      'quantity': prevQty + quantity,
      'costPrice': costPrice, // latest cost
      'note': note ?? "",
      'date': DateTime.now(),
    });
  } else {
    await ref.set({
      'productId': productId,
      'warehouseId': warehouseId,
      'costPrice': costPrice,
      'quantity': quantity,
      'note': note ?? "",
      'date': DateTime.now(),
    });
  }
}



Future<void> addStockOutSeparate(
  String productId,
  String warehouseId,
  int quantity,
  String? note,
) async {
  // 1) Write a log row (history)
  await _db.collection('stock_out_logs').add({
    'productId': productId,
    'warehouseId': warehouseId,
    'quantity': quantity,
    'note': note ?? "",
    'date': DateTime.now(),
  });

  // 2) Update aggregated stock_out doc (for instant inventory)
  final docId = "${productId}_$warehouseId";
  final ref = _db.collection('stock_out').doc(docId);
  final snap = await ref.get();

  if (snap.exists) {
    final prevQty = (snap.data()?['quantity'] as int?) ?? 0;
    await ref.update({
      'quantity': prevQty + quantity,
      'date': DateTime.now(),
    });
  } else {
    await ref.set({
      'productId': productId,
      'warehouseId': warehouseId,
      'quantity': quantity,
      'note': note ?? "",
      'date': DateTime.now(),
    });
  }
}




}
