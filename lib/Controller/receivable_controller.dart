import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/Model/receivable_model.dart';
import 'package:inventory_management_app/services/local_storage.dart';
import '../services/firestore_service.dart';


class ReceivableController extends GetxController {
  final FirestoreService _fs = Get.find<FirestoreService>();
  final LocalUserService _local = Get.find<LocalUserService>();

  var receivables = <ReceivableModel>[].obs;
  var loading = false.obs;
  String? deviceUserId;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    deviceUserId = await _local.getDeviceUserId();
    _fs.receivablesStream().listen((list) {
      receivables.value = list.map((m) => ReceivableModel.fromMap(m, m['id'])).toList();
    });
  }

  Future<void> createReceivable({
    required String customerName,
    required double totalAmount,
    required DateTime dueDate,
    String refNo = '',
    String notes = '',
  }) async {
    loading.value = true;
    try {
      final createdBy = deviceUserId ?? await _local.getDeviceUserId();
      final payload = {
        'customerName': customerName,
        'totalAmount': totalAmount,
        'outstanding': totalAmount,
        'refNo': refNo,
        'dueDate': Timestamp.fromDate(dueDate),
        'notes': notes,
        'createdBy': createdBy,
      };
      await _fs.createReceivable(payload);
      Get.snackbar('Success', 'Receivable added');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      loading.value = false;
    }
  }

  /// add payment or adjustment
  Future<void> addPayment(String receivableId, double amount, String type, String note) async {
    loading.value = true;
    try {
      final createdBy = deviceUserId ?? await _local.getDeviceUserId();
      final payment = {
        'amount': amount,
        'type': type,
        'note': note,
        'createdBy': createdBy,
      };
      await _fs.addReceivablePayment(receivableId, payment);
      Get.snackbar('Success', type == 'payment' ? 'Payment recorded' : 'Adjustment recorded');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      loading.value = false;
    }
  }

  Stream<List<Map<String,dynamic>>> paymentsStream(String receivableId) {
    return _fs.paymentsStream(receivableId);
  }

  bool canEdit(Map<String,dynamic> doc) {
    final createdBy = doc['createdBy'] as String?;
    return createdBy != null && deviceUserId != null && createdBy == deviceUserId;
  }
}
