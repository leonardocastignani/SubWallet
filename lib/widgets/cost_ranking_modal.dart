import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

void showCostRankingModal(BuildContext context, List<QueryDocumentSnapshot> subscriptions) {
  showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => _CostRankingModalContent(subscriptions: subscriptions));
}

class _CostRankingModalContent extends StatefulWidget {
  final List<QueryDocumentSnapshot> subscriptions;
  const _CostRankingModalContent({required this.subscriptions});
  @override
  State<_CostRankingModalContent> createState() => _CostRankingModalContentState();
}

class _CostRankingModalContentState extends State<_CostRankingModalContent> {
  List<Map<String, dynamic>> _rankedSubscriptions = [];
  double _grandTotal = 0;

  @override
  void initState() {
    super.initState();
    _calculateRanking();
  }

  void _calculateRanking() {
    List<Map<String, dynamic>> temp = [];
    double total = 0;
    for (var doc in widget.subscriptions) {
      final data = doc.data() as Map<String, dynamic>;
      final String name = data['serviceName'] ?? 'Sconosciuto';
      final double price = (data['price'] ?? 0).toDouble();
      final String cycle = data['cycle'] ?? 'Mensile';
      final String category = data['category'] ?? 'Altro';
      final double monthlyPrice = cycle == 'Annuale' ? price / 12 : price;
      total += monthlyPrice;
      temp.add({'name': name, 'monthlyPrice': monthlyPrice, 'category': category});
    }
    temp.sort((a, b) => (b['monthlyPrice'] as double).compareTo(a['monthlyPrice'] as double));
    for (var item in temp) { item['percentage'] = total > 0 ? ((item['monthlyPrice'] as double) / total) * 100 : 0.0; }
    setState(() { _rankedSubscriptions = temp; _grandTotal = total; });
  }

  Color _getRankColor(int index) {
    if (index == 0) return CupertinoColors.systemYellow;
    if (index == 1) return CupertinoColors.systemGrey;
    if (index == 2) return CupertinoColors.systemOrange;
    return CupertinoColors.systemGrey4;
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SettingsProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: const BoxDecoration(color: Color(0xFFF2F2F7), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          Container(margin: const EdgeInsets.only(top: 12, bottom: 8), width: 40, height: 5, decoration: BoxDecoration(color: CupertinoColors.systemGrey4, borderRadius: BorderRadius.circular(10))),
          Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(prov.t('rank_title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5))),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [const Icon(CupertinoIcons.list_number, color: CupertinoColors.systemPink, size: 20), const SizedBox(width: 8), Text(prov.t('wallet_impact'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: CupertinoColors.systemGrey))]),
                      const SizedBox(height: 12),
                      Text('${prov.currency}${_grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
                      Text('${_rankedSubscriptions.length} ${prov.t('subs_analyzed')}', style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGrey)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(children: [const Icon(CupertinoIcons.sort_down, color: CupertinoColors.systemPink, size: 18), const SizedBox(width: 6), Text(prov.t('expensive_to_cheap'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CupertinoColors.systemGrey, letterSpacing: 1.2))]),
                const SizedBox(height: 12),

                if (_rankedSubscriptions.isEmpty)
                  Padding(padding: const EdgeInsets.all(24.0), child: Center(child: Text(prov.t('no_subs_rank'), style: const TextStyle(color: CupertinoColors.systemGrey))))
                else
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: _rankedSubscriptions.asMap().entries.map((entry) {
                        final int index = entry.key; final Map<String, dynamic> item = entry.value; final bool isLast = index == _rankedSubscriptions.length - 1;
                        final double percentage = item['percentage']; final Color rankColor = _getRankColor(index); final bool isTop3 = index < 3;

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Container(width: 36, height: 36, decoration: BoxDecoration(color: isTop3 ? rankColor.withValues(alpha: 0.15) : rankColor.withValues(alpha: 0.3), shape: BoxShape.circle), child: Center(child: Text('${index + 1}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isTop3 ? rankColor : CupertinoColors.systemGrey)))),
                                  const SizedBox(width: 14),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(prov.tCat(item['category']), style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGrey))])),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('${prov.currency}${item['monthlyPrice'].toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Row(children: [Text('${percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey, fontWeight: FontWeight.w600)), const SizedBox(width: 6), Container(width: 40, height: 4, decoration: BoxDecoration(color: CupertinoColors.systemGrey6, borderRadius: BorderRadius.circular(2)), alignment: Alignment.centerLeft, child: Container(width: 40 * (percentage / 100), height: 4, decoration: BoxDecoration(color: CupertinoColors.systemPink, borderRadius: BorderRadius.circular(2))))]),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast) const Divider(height: 1, indent: 66, color: Color(0xFFF3F3F3)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}