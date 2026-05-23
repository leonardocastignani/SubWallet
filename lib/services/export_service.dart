import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  Future<void> exportMonthlyReportCSV(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('subscriptions')
          .where('userId', isEqualTo: user.uid)
          .get();

      final subscriptions = snapshot.docs;
      
      StringBuffer csvContent = StringBuffer();
      csvContent.writeln("Servizio,Costo,Ciclo di Fatturazione,Data Prossimo Rinnovo");

      double totalMonthlySpend = 0;

      for (var doc in subscriptions) {
        final data = doc.data();
        final String name = data['serviceName'] ?? 'Sconosciuto';
        final double price = (data['price'] ?? 0).toDouble();
        final String cycle = data['cycle'] ?? 'Mensile';
        
        String renewalDateStr = "N/A";
        if (data['renewalDate'] != null) {
          final DateTime date = (data['renewalDate'] as Timestamp).toDate();
          renewalDateStr = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
        }

        if (cycle == 'Annuale') {
          totalMonthlySpend += (price / 12);
        } else {
          totalMonthlySpend += price;
        }

        final cleanName = name.replaceAll(',', ' ');
        csvContent.writeln("$cleanName,€${price.toStringAsFixed(2)},$cycle,$renewalDateStr");
      }

      csvContent.writeln("");
      csvContent.writeln("TOTALE SPESA MENSILE STIMATA,€${totalMonthlySpend.toStringAsFixed(2)},,");

      final directory = await getTemporaryDirectory();
      
      final months = [
        'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
        'Luglio', 'Agosto', 'Settembre', 'Octobre', 'Novembre', 'Dicembre'
      ];
      final now = DateTime.now();
      int prevMonthIdx = now.month - 2;
      int year = now.year;
      if (prevMonthIdx < 0) {
        prevMonthIdx = 11;
        year--;
      }
      final String prevMonthName = months[prevMonthIdx];
      
      final String filePath = '${directory.path}/SubWallet_Report_${prevMonthName}_$year.csv';
      
      final File file = File(filePath);
      await file.writeAsString(csvContent.toString());

      final xFile = XFile(filePath);
      
      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: 'Ecco il mio report di $prevMonthName $year delle spese da SubWallet!',
        ),
      );

    } catch (e) {
      debugPrint("Errore durante l'esportazione: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore durante la creazione del report.'), backgroundColor: Colors.red),
        );
      }
    }
  }
}