import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> addSubscription({
    required String serviceName,
    required String domain,
    required double price,
    required String cycle,
    required String paymentMethod,
    required DateTime nextRenewal,
    required String notes,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        debugPrint("Errore: Utente non autenticato.");
        return false;
      }

      await _db.collection('subscriptions').add({
        'userId': user.uid,
        'serviceName': serviceName,
        'domain': domain,
        'price': price,
        'cycle': cycle,
        'paymentMethod': paymentMethod,
        'nextRenewal': Timestamp.fromDate(nextRenewal),
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint("Abbonamento $serviceName salvato con successo per ${user.displayName}!");
      return true;
    } catch (e) {
      debugPrint("Errore durante il salvataggio su Firestore: $e");
      return false;
    }
  }

  Future<bool> deleteSubscription(String docId) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return false;

      await _db.collection('subscriptions').doc(docId).delete();
      
      debugPrint("Abbonamento $docId eliminato con successo!");
      return true;
    } catch (e) {
      debugPrint("Errore durante l'eliminazione: $e");
      return false;
    }
  }
}