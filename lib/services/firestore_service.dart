import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot> getTransactions() {
    return db
        .collection("transactions")
        .where("uid", isEqualTo: uid)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Future addTransaction({
    required String title,
    required double amount,
    required String category,
    required String type,
  }) async {
    await db.collection("transactions").add({
      "title": title,
      "amount": amount,
      "category": category,
      "type": type,
      "uid": uid,
      "timestamp": Timestamp.now(),
    });
  }

  Future updateTransaction({
    required String id,
    required String title,
    required double amount,
    required String category,
    required String type,
  }) async {
    await db.collection("transactions").doc(id).update({
      "title": title,
      "amount": amount,
      "category": category,
      "type": type,
    });
  }

  Future deleteTransaction(String id) async {
    await db.collection("transactions").doc(id).delete();
  }
}
