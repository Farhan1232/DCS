import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class WarehouseController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var warehouses = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchWarehouses();
  }

  void fetchWarehouses() {
    _db.collection('warehouses').snapshots().listen((snapshot) {
      warehouses.value =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

  Future<void> addWarehouse(String name, String location) async {
    await _db.collection('warehouses').add({'name': name, 'location': location});
  }

  Future<void> editWarehouse(String id, String name, String location) async {
    await _db
        .collection('warehouses')
        .doc(id)
        .update({'name': name, 'location': location});
  }

  Future<void> deleteWarehouse(String id) async {
    await _db.collection('warehouses').doc(id).delete();
  }
}
