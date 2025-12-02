import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var products = [].obs;
  var categories = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchCategories();
  }

  void fetchProducts() {
    _db.collection('products').snapshots().listen((snapshot) {
      products.value =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

  void fetchCategories() {
    _db.collection('categories').snapshots().listen((snapshot) {
      categories.value =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

  Future<void> addProduct(String name, String categoryId) async {
    await _db.collection('products').add({
      'name': name,
      'categoryId': categoryId,
    });
  }

  Future<void> editProduct(String id, String name, String categoryId) async {
    await _db.collection('products').doc(id).update({
      'name': name,
      'categoryId': categoryId,
    });
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }
}
