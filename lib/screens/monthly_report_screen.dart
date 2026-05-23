import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/export_service.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  bool _isReportEnabled = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isReportEnabled = prefs.getBool('monthlyReportEnabled') ?? true;
    });
  }

  Future<void> _toggleReport(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('monthlyReportEnabled', value);
    setState(() {
      _isReportEnabled = value;
    });
    
    await NotificationService().scheduleMonthlyReport(enable: value);
  }

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    await ExportService().exportMonthlyReportCSV(context);
    setState(() => _isExporting = false);
  }

  String _getPreviousMonthName() {
    final months = [
      'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
    ];
    int prevMonthIdx = DateTime.now().month - 2;
    if (prevMonthIdx < 0) {
      prevMonthIdx = 11;
    }
    return months[prevMonthIdx];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Mensile'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9FC9FF), Color(0xFFF2F2F7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.25],
              ),
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 32),
                
                const Padding(
                  padding: EdgeInsets.only(left: 32, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('NOTIFICA RIEPILOGATIVA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CupertinoColors.systemGrey, letterSpacing: 1.1)),
                  ),
                ),
                
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: CupertinoListTile(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    title: const Text('Ricevi il report mensile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                    trailing: CupertinoSwitch(
                      value: _isReportEnabled,
                      activeTrackColor: const Color(0xFF007AFF),
                      onChanged: _toggleReport,
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Se attivato, riceverai una notifica il 1° giorno di ogni mese alle 10:00 del mattino con l\'invito a consultare il riepilogo delle tue spese.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: CupertinoColors.systemGrey, height: 1.4),
                  ),
                ),

                const SizedBox(height: 16),

                const Padding(
                  padding: EdgeInsets.only(left: 32, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('ESPORTA DATI (CSV)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CupertinoColors.systemGrey, letterSpacing: 1.1)),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    onPressed: _isExporting ? null : _handleExport,
                    child: SizedBox(
                      height: 56,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isExporting)
                            const CupertinoActivityIndicator(radius: 12)
                          else ...[
                            const Icon(CupertinoIcons.arrow_down_doc_fill, color: Color(0xFF007AFF), size: 22),
                            const SizedBox(width: 10),
                            Text('Scarica Report di ${_getPreviousMonthName()}', style: const TextStyle(color: Color(0xFF007AFF), fontSize: 17, fontWeight: FontWeight.w600)),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}