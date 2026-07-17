import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String id;
  String title;
  double amount;
  String category;
  String type;
  Timestamp timestamp;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.timestamp,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TransactionModel(
      id: doc.id,
      title: data["title"],
      amount: (data["amount"] as num).toDouble(),
      category: data["category"],
      type: data["type"],
      timestamp: data["timestamp"],
    );
  }
}
