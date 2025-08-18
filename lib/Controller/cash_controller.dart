// lib/controllers/cash_controller.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/Model/cash_entry.dart';


enum FilterPeriod { all, today, weekly, monthly, yearly }

class CashController extends GetxController {
  CashController({this.userId = 'demo'});

  final String userId;
  final _db = FirebaseFirestore.instance;

  final RxList<CashEntry> _entries = <CashEntry>[].obs;
  final Rx<FilterPeriod> filter = FilterPeriod.all.obs;

  StreamSubscription? _sub;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(userId).collection('cash_entries');

  @override
  void onInit() {
    super.onInit();
    _bind();
  }

  void _bind() {
    _sub?.cancel();
    _sub = _col.orderBy('timestamp', descending: true).snapshots().listen(
      (snap) {
        _entries.value =
            snap.docs.map((d) => CashEntry.fromDoc(d)).toList(growable: false);
      },
    );
  }

  List<CashEntry> get entries => _entries;

  Future<void> addEntry({
    required double amount,
    required bool isCashIn,
    required String note,
    required DateTime when,
  }) async {
    await _col.add({
      'amount': amount,
      'type': isCashIn ? 'in' : 'out',
      'note': note,
      'timestamp': Timestamp.fromDate(when),
    });
  }

  // Filtering helpers
  DateTime? _startFor(FilterPeriod p) {
    final now = DateTime.now();
    switch (p) {
      case FilterPeriod.all:
        return null;
      case FilterPeriod.today:
        return DateTime(now.year, now.month, now.day);
      case FilterPeriod.weekly:
        return now.subtract(const Duration(days: 7));
      case FilterPeriod.monthly:
        return DateTime(now.year, now.month, 1);
      case FilterPeriod.yearly:
        return DateTime(now.year, 1, 1);
    }
  }

  List<CashEntry> get filtered {
    final start = _startFor(filter.value);
    if (start == null) return entries;
    return entries.where((e) => !e.timestamp.isBefore(start)).toList();
  }

  double get totalIn =>
      filtered.where((e) => e.type == 'in').fold(0.0, (a, e) => a + e.amount);

  double get totalOut =>
      filtered.where((e) => e.type == 'out').fold(0.0, (a, e) => a + e.amount);

  double get balance => totalIn - totalOut;

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
