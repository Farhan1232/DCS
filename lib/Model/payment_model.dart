import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final double amount;
  final String type; // 'payment' | 'adjustment'
  final String note;
  final DateTime timestamp;
  final String createdBy;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.note,
    required this.timestamp,
    required this.createdBy,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    final Timestamp? t = map['timestamp'] as Timestamp?;
    return PaymentModel(
      id: id,
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? 'payment',
      note: map['note'] ?? '',
      timestamp: t?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? '',
    );
  }
}
