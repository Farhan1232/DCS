// lib/models/cash_entry.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CashEntry {
  final String id;
  final double amount;
  final String type; // 'in' or 'out'
  final String note;
  final DateTime timestamp;

  CashEntry({
    required this.id,
    required this.amount,
    required this.type,
    required this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'type': type,
        'note': note,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  factory CashEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return CashEntry(
      id: doc.id,
      amount: (d['amount'] as num).toDouble(),
      type: d['type'] as String,
      note: (d['note'] ?? '') as String,
      timestamp: (d['timestamp'] as Timestamp).toDate(),
    );
  }
}
