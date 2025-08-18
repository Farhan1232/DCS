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

  // Selected dropdown persistence (if needed elsewhere)
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
  // Fetch master data
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
  // Stock In / Stock Out (IDs only)
  // ------------------------

  Future<void> addStockIn(
  String productId,
  String warehouseId,
  double costPrice,
  int quantity,
) async {
  // Check if a document already exists for this (productId, warehouseId)
  final existingDocs = await _db
      .collection('stock_in')
      .where('productId', isEqualTo: productId)
      .where('warehouseId', isEqualTo: warehouseId)
      .get();

  if (existingDocs.docs.isNotEmpty) {
    // ✅ Update the existing doc
    final doc = existingDocs.docs.first;
    final prevQty = doc['quantity'] as int;
    final prevPrice = (doc['costPrice'] as num).toDouble();

    await doc.reference.update({
      'quantity': prevQty + quantity, // Add new qty
      'costPrice': costPrice,         // Replace price with latest
      'date': DateTime.now(),         // Update timestamp
    });
  } else {
    // ✅ Create a new doc if no match
    await _db.collection('stock_in').add({
      'productId': productId,
      'warehouseId': warehouseId,
      'costPrice': costPrice,
      'quantity': quantity,
      'date': DateTime.now(),
    });
  }
}

  Future<void> addStockOut(
    String productId,
    String warehouseId,
    int quantity,
  ) async {
    // Guard: write only IDs
    await _db.collection('stock_out').add({
      'productId': productId,
      'warehouseId': warehouseId,
      'quantity': quantity,
      'date': DateTime.now(),
    });
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

    final existingDocs = await _db
        .collection('stock_in')
        .where('productId', isEqualTo: productId)
        .where('warehouseId', isEqualTo: warehouseId)
        .get();

    if (existingDocs.docs.isNotEmpty) {
      // ✅ Update existing
      final doc = existingDocs.docs.first;
      final prevQty = doc['quantity'] as int;

      await doc.reference.update({
        'quantity': prevQty + quantity,
        'costPrice': costPrice,   // latest price
        'date': DateTime.now(),
      });
    } else {
      // ✅ Create new
      await _db.collection('stock_in').add({
        'productId': productId,
        'warehouseId': warehouseId,
        'costPrice': costPrice,
        'quantity': quantity,
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

  Future<int> getAvailableQuantity(String productId, String warehouseId) async {
    final stockInSnap = await _db
        .collection('stock_in')
        .where('productId', isEqualTo: productId)
        .where('warehouseId', isEqualTo: warehouseId)
        .get();

    final totalIn =
        stockInSnap.docs.fold(0, (sum, d) => sum + (d['quantity'] as int));

    final stockOutSnap = await _db
        .collection('stock_out')
        .where('productId', isEqualTo: productId)
        .where('warehouseId', isEqualTo: warehouseId)
        .get();

    final totalOut =
        stockOutSnap.docs.fold(0, (sum, d) => sum + (d['quantity'] as int));

    return totalIn - totalOut;
  }

  // ------------------------
  // Inventory with accurate price
  // ------------------------

  void fetchInventory() {
    _db.collection('stock_in').snapshots().listen((stockSnap) async {
      if (products.isEmpty || warehouses.isEmpty) return;

      final List<Map<String, dynamic>> inventoryList = [];

      for (final product in products) {
        for (final warehouse in warehouses) {
          // Filter docs for this (productId, warehouseId)
          final docs = stockSnap.docs
              .where((d) =>
                  d['productId'] == product['id'] &&
                  d['warehouseId'] == warehouse['id'])
              .toList();

          // totalIn
          final totalIn = docs.fold<int>(
              0, (sum, d) => sum + (d['quantity'] as int));

          // totalOut
          final stockOutSnap = await _db
              .collection('stock_out')
              .where('productId', isEqualTo: product['id'])
              .where('warehouseId', isEqualTo: warehouse['id'])
              .get();

          final totalOut = stockOutSnap.docs
              .fold<int>(0, (sum, d) => sum + (d['quantity'] as int));

          final availableQty = totalIn - totalOut;

          if (availableQty > 0) {
            // sort by date to get true latest price
            docs.sort((a, b) {
              DateTime ad = _asDate(a['date']);
              DateTime bd = _asDate(b['date']);
              return ad.compareTo(bd);
            });

            double latestPrice = 0;
            if (docs.isNotEmpty) {
              final last = docs.last;
              final cp = last.data().containsKey('costPrice')
                  ? last['costPrice']
                  : 0;
              latestPrice = (cp as num).toDouble();
            }

            inventoryList.add({
              'productId': product['id'],
              'productName': product['name'],
              'warehouseId': warehouse['id'],
              'warehouseName': warehouse['name'],
              'quantity': availableQty,
              'price': latestPrice,
              'categoryId': product['categoryId'],
              'date': docs.isNotEmpty ? _asDate(docs.last['date']) : DateTime.now(),
            });
          }
        }
      }

      inventory.value = inventoryList;
    });
  }

  DateTime _asDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  // ------------------------
  // Real-time sanitizers (fix & remove name fields)
  // ------------------------

  void _startSanitizers() {
    if (_sanitizersStarted) return;
    _sanitizersStarted = true;

    // Watch & sanitize stock_in
    _db.collection('stock_in').snapshots().listen((snap) {
      _sanitizeDocs(snap.docs, 'stock_in');
    });

    // Watch & sanitize stock_out
    _db.collection('stock_out').snapshots().listen((snap) {
      _sanitizeDocs(snap.docs, 'stock_out');
    });
  }

  Future<void> _sanitizeDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String collectionName,
  ) async {
    // Need master data to map names -> IDs
    if (products.isEmpty || warehouses.isEmpty) return;

    // Build lowercase maps for robust matching
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

      // If IDs missing but names present → try to recover IDs
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

      // Delete name fields ONLY if the doc will have IDs after this update
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
}
