import 'package:cloud_firestore/cloud_firestore.dart';

class ReceivableModel {
  final String id;
  final String customerName;
  final double totalAmount;
  final double outstanding;
  final String refNo;
  final DateTime? dueDate;
  final String notes;
  final String status; // Open/Closed/Overdue
  final DateTime createdAt;
  final String createdBy;

  ReceivableModel({
    required this.id,
    required this.customerName,
    required this.totalAmount,
    required this.outstanding,
    required this.refNo,
    required this.dueDate,
    required this.notes,
    required this.status,
    required this.createdAt,
    required this.createdBy,
  });

  factory ReceivableModel.fromMap(Map<String, dynamic> map, String id) {
    final Timestamp? t = map['dueDate'] as Timestamp?;
    final Timestamp? created = map['createdAt'] as Timestamp?;
    return ReceivableModel(
      id: id,
      customerName: map['customerName'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      outstanding: (map['outstanding'] ?? 0).toDouble(),
      refNo: map['refNo'] ?? '',
      dueDate: t?.toDate(),
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'Open',
      createdAt: created?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? '',
    );
  }
}
