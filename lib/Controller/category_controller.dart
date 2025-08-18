import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var categories = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  void fetchCategories() {
    _db.collection('categories').snapshots().listen((snapshot) {
      categories.value =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

  Future<void> addCategory(String name) async {
    await _db.collection('categories').add({'name': name});
  }

  Future<void> editCategory(String id, String name) async {
    await _db.collection('categories').doc(id).update({'name': name});
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection('categories').doc(id).delete();
  }
}
