// RECEIVABLES

import 'package:cloud_firestore/cloud_firestore.dart';
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


// RECEIVABLES

Stream<List<Map<String, dynamic>>> receivablesStream({String? status}) {
  Query q = _db.collection('receivables').orderBy('createdAt', descending: true);
  if (status != null && status.isNotEmpty) {
    q = q.where('status', isEqualTo: status);
  }
  return q.snapshots().map((snap) {
    return snap.docs.map((d) {
      final m = d.data() as Map<String, dynamic>;
      m['id'] = d.id;
      return m;
    }).toList();
  });
}

Future<DocumentReference> createReceivable(Map<String, dynamic> data) async {
  final docRef = _db.collection('receivables').doc();
  final payload = {
    ...data,
    'createdAt': FieldValue.serverTimestamp(),
    'status': data['status'] ?? 'Open',
    'outstanding': data['totalAmount'],
  };
  await docRef.set(payload);
  return docRef;
}

Future<Map<String, dynamic>?> getReceivable(String id) async {
  final doc = await _db.collection('receivables').doc(id).get();
  if (!doc.exists) return null;
  final m = doc.data() as Map<String, dynamic>;
  m['id'] = doc.id;
  return m;
}

/// Add a payment or adjustment to a receivable in a transaction-safe way.
/// paymentMap: { amount: double, type: 'payment'|'adjustment', note: string, createdBy: string }
Future<void> addReceivablePayment(String receivableId, Map<String, dynamic> paymentMap) async {
  final docRef = _db.collection('receivables').doc(receivableId);
  await _db.runTransaction((tx) async {
    final snapshot = await tx.get(docRef);
    if (!snapshot.exists) throw Exception('Receivable not found');
    final data = snapshot.data() as Map<String, dynamic>;
    double outstanding = (data['outstanding'] ?? 0).toDouble();
    final double amount = (paymentMap['amount'] ?? 0).toDouble();
    final String type = paymentMap['type'] ?? 'payment';

    double newOutstanding = outstanding;
    if (type == 'payment') {
      newOutstanding = outstanding - amount;
      if (newOutstanding < 0) newOutstanding = 0; // do not allow negative outstanding
    } else if (type == 'adjustment') {
      // adjustment can increase or decrease outstanding depending on sign of amount
      newOutstanding = outstanding + amount; // amount can be negative to reduce outstanding
      if (newOutstanding < 0) newOutstanding = 0;
    }

    // update receivable outstanding and status
    final status = newOutstanding <= 0 ? 'Closed' : 'Open';
    tx.update(docRef, {'outstanding': newOutstanding, 'status': status});

    // add payment subdoc
    final paymentsRef = docRef.collection('payments').doc();
    final paymentPayload = {
      'amount': amount,
      'type': type,
      'note': paymentMap['note'] ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'createdBy': paymentMap['createdBy'] ?? '',
    };
    tx.set(paymentsRef, paymentPayload);
  });
}

Stream<List<Map<String, dynamic>>> paymentsStream(String receivableId) {
  return _db
      .collection('receivables')
      .doc(receivableId)
      .collection('payments')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) {
            final m = d.data() as Map<String, dynamic>;
            m['id'] = d.id;
            return m;
          }).toList());
}

// optional: update or delete receivable
Future<void> updateReceivable(String id, Map<String, dynamic> data) {
  return _db.collection('receivables').doc(id).update(data);
}

Future<void> deleteReceivable(String id) {
  return _db.collection('receivables').doc(id).delete();
}






  // ✅ Fetch stock_in collection
  Future<List<Map<String, dynamic>>> fetchStockIn() async {
    final snapshot = await _db.collection("stock_in").get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // ✅ Fetch purchase_orders collection
  Future<List<Map<String, dynamic>>> fetchPurchaseOrders() async {
    final snapshot = await _db.collection("purchase_orders").get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }
}




