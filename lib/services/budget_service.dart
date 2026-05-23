import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';

class BudgetService {
  static Future<void> checkBudgetAfterAddition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isEnabled = prefs.getBool('budgetAlertEnabled') ?? false;
      
      if (!isEnabled) return;

      final double threshold = prefs.getDouble('budgetThreshold') ?? 50.0;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('subscriptions')
          .where('userId', isEqualTo: user.uid)
          .get();

      double totalMonthlySpend = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final double price = (data['price'] ?? 0).toDouble();
        final String cycle = data['cycle'] ?? 'Mensile';
        
        if (cycle == 'Annuale') {
          totalMonthlySpend += (price / 12);
        } else {
          totalMonthlySpend += price;
        }
      }

      if (totalMonthlySpend > threshold) {
        await NotificationService().showBudgetAlert(totalMonthlySpend, threshold);
      }
    } catch (e) {
      debugPrint("Errore nel controllo budget: $e");
    }
  }
}