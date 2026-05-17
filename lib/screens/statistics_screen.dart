import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../widgets/category_chart_modal.dart';
import '../widgets/trend_chart_modal.dart';
import '../widgets/payment_calendar_modal.dart';
import '../widgets/cost_ranking_modal.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
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
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('subscriptions').where('userId', isEqualTo: user?.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CupertinoActivityIndicator(radius: 16));
                if (snapshot.hasError) return const Center(child: Text('Errore nel caricamento dei dati.'));

                final subscriptions = snapshot.data?.docs ?? [];
                double totalMonthlySpend = 0;

                for (var doc in subscriptions) {
                  final data = doc.data() as Map<String, dynamic>;
                  final double price = (data['price'] ?? 0).toDouble();
                  final String cycle = data['cycle'] ?? 'Mensile';
                  if (cycle == 'Annuale') { totalMonthlySpend += (price / 12); } else { totalMonthlySpend += price; }
                }

                final double totalAnnualSpend = totalMonthlySpend * 12;
                final int totalSubs = subscriptions.length;
                final double avgCost = totalSubs > 0 ? (totalMonthlySpend / totalSubs) : 0.0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16, bottom: 8),
                        child: Text(
                          'STATISTICHE',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CupertinoColors.systemGrey, letterSpacing: 1.2),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _buildMetricCard('Spesa mensile', '€${totalMonthlySpend.toStringAsFixed(2)}', '+€0 vs mese scorso')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildMetricCard('Spesa annuale', '€${totalAnnualSpend.toStringAsFixed(2)}', 'proiettata')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _buildMetricCard('N° abbonamenti', '$totalSubs', 'attivi ora')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildMetricCard('Costo medio', '€${avgCost.toStringAsFixed(2)}', 'per abbonamento/mese')),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      const Text('DETTAGLI', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CupertinoColors.systemGrey, letterSpacing: 1.2)),
                      const SizedBox(height: 12),

                      _buildDetailTile(
                        icon: CupertinoIcons.chart_pie_fill, iconColor: CupertinoColors.activeGreen,
                        title: 'Spesa per categoria', subtitle: 'Streaming, produttività, gaming, news',
                        onTap: () => showCategoryChartModal(context, subscriptions),
                      ),
                      _buildDetailTile(
                        icon: CupertinoIcons.graph_square_fill, iconColor: CupertinoColors.activeBlue,
                        title: 'Andamento nel tempo', subtitle: 'Grafico a linee degli ultimi 6 mesi',
                        onTap: () => showTrendChartModal(context, subscriptions),
                      ),
                      _buildDetailTile(
                        icon: CupertinoIcons.calendar, iconColor: CupertinoColors.systemOrange,
                        title: 'Calendario pagamenti', subtitle: 'Visualizzazione di quando escono i soldi',
                        onTap: () => showPaymentCalendarModal(context, subscriptions),
                      ),
                      _buildDetailTile(
                        icon: CupertinoIcons.list_number, iconColor: CupertinoColors.systemPink,
                        title: 'Classifica per costo', subtitle: 'Dal più caro al più economico',
                        onTap: () => showCostRankingModal(context, subscriptions),
                      ),
                      _buildDetailTile(
                        icon: CupertinoIcons.sparkles, iconColor: CupertinoColors.systemPurple,
                        title: 'Insight intelligenti (AI)', subtitle: 'Analisi automatica e consigli di risparmio',
                        onTap: () => Fluttertoast.showToast(msg: "Insight AI in arrivo a breve! 🚀", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, backgroundColor: const Color(0xFF333333), textColor: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey2)),
        ],
      ),
    );
  }

  Widget _buildDetailTile({required IconData icon, required Color iconColor, required String title, required String subtitle, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))]),
      child: CupertinoListTile(
        padding: const EdgeInsets.all(16), leadingSize: 44,
        leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 24)),
        title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(subtitle, style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGrey))),
        trailing: const Icon(CupertinoIcons.chevron_right, color: CupertinoColors.systemGrey4, size: 20),
        onTap: onTap,
      ),
    );
  }
}