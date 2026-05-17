import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showCategoryChartModal(BuildContext context, List<QueryDocumentSnapshot> subscriptions) {
  showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => _CategoryChartModalContent(subscriptions: subscriptions));
}

class _CategoryChartModalContent extends StatefulWidget {
  final List<QueryDocumentSnapshot> subscriptions;
  const _CategoryChartModalContent({required this.subscriptions});
  @override
  State<_CategoryChartModalContent> createState() => _CategoryChartModalContentState();
}

class _CategoryChartModalContentState extends State<_CategoryChartModalContent> {
  int touchedIndex = -1;

  final Map<String, Color> categoryColors = {
    'Intrattenimento': const Color(0xFF8EBBFF), 'Produttività': const Color(0xFFC9A2FF), 'Gaming': const Color(0xFFFF9F9F),
    'Informazione': const Color(0xFF86E3E9), 'Salute e Sport': const Color(0xFFFFD18D), 'Utility': const Color(0xFFC7E298), 'Altro': CupertinoColors.systemGrey4,
  };

  @override
  Widget build(BuildContext context) {
    Map<String, double> categoryTotals = {};
    double grandTotal = 0;

    for (var doc in widget.subscriptions) {
      final data = doc.data() as Map<String, dynamic>;
      final double price = (data['price'] ?? 0).toDouble();
      final String cycle = data['cycle'] ?? 'Mensile';
      final String category = data['category'] ?? 'Altro';

      final double monthlyPrice = cycle == 'Annuale' ? price / 12 : price;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + monthlyPrice;
      grandTotal += monthlyPrice;
    }

    var sortedCategories = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    String selectedCategoryName = 'Totale';
    double selectedCategoryValue = grandTotal;
    Color selectedColor = CupertinoColors.inactiveGray;

    if (touchedIndex != -1 && touchedIndex < sortedCategories.length) {
      var entry = sortedCategories[touchedIndex];
      selectedCategoryName = entry.key;
      selectedCategoryValue = entry.value;
      selectedColor = categoryColors[entry.key] ?? CupertinoColors.inactiveGray;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: const BoxDecoration(color: Color(0xFFF2F2F7), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          Container(margin: const EdgeInsets.only(top: 12, bottom: 8), width: 40, height: 5, decoration: BoxDecoration(color: CupertinoColors.systemGrey4, borderRadius: BorderRadius.circular(10))),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Spesa per categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5))),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 250, height: 250,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(width: 190, height: 190, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 10))])),
                        PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) { touchedIndex = -1; return; }
                                touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            }),
                            borderData: FlBorderData(show: false), sectionsSpace: 3, centerSpaceRadius: 75, sections: _buildChartSections(sortedCategories),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: selectedColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(selectedCategoryName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: selectedColor, letterSpacing: 0.5))),
                            const SizedBox(height: 6),
                            Text('€${selectedCategoryValue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -1)),
                            const Text('/mese', style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey2)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Row(children: [Icon(CupertinoIcons.chart_pie_fill, color: CupertinoColors.activeGreen, size: 18), SizedBox(width: 6), Text('DETTAGLIO MENSILE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CupertinoColors.systemGrey, letterSpacing: 1.2))]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: sortedCategories.map((entry) {
                      final isLast = entry.key == sortedCategories.last.key;
                      final percentage = (entry.value / grandTotal * 100).toStringAsFixed(1);
                      final color = categoryColors[entry.key] ?? CupertinoColors.systemGrey;
                      return Column(
                        children: [
                          CupertinoListTile(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), leading: Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle), child: Center(child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)))),
                            title: Text(entry.key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            subtitle: Text('$percentage%', style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGrey)),
                            trailing: Text('€${entry.value.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          if (!isLast) const Divider(height: 1, indent: 64, color: Color(0xFFF3F3F3)),
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

  List<PieChartSectionData> _buildChartSections(List<MapEntry<String, double>> sortedCategories) {
    return List.generate(sortedCategories.length, (i) {
      final isTouched = i == touchedIndex;
      final entry = sortedCategories[i];
      final color = categoryColors[entry.key] ?? CupertinoColors.systemGrey;
      return PieChartSectionData(color: color, value: entry.value, title: '', radius: isTouched ? 22.0 : 18.0, titleStyle: const TextStyle(color: Colors.transparent));
    });
  }
}