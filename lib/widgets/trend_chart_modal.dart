import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showTrendChartModal(BuildContext context, List<QueryDocumentSnapshot> subscriptions) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _TrendChartModalContent(subscriptions: subscriptions),
  );
}

class _TrendChartModalContent extends StatefulWidget {
  final List<QueryDocumentSnapshot> subscriptions;

  const _TrendChartModalContent({required this.subscriptions});

  @override
  State<_TrendChartModalContent> createState() => _TrendChartModalContentState();
}

class _TrendChartModalContentState extends State<_TrendChartModalContent> {
  List<FlSpot> _spots = [];
  List<String> _monthLabels = [];
  double _maxSpend = 0;
  double _currentSpend = 0;

  @override
  void initState() {
    super.initState();
    _calculateTrend();
  }

  String _getMonthName(int month) {
    const months = ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'];
    return months[month - 1];
  }

  void _calculateTrend() {
    final now = DateTime.now();
    List<FlSpot> tempSpots = [];
    List<String> tempLabels = [];
    double tempMax = 0;

    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      tempLabels.add(_getMonthName(targetDate.month));

      double monthTotal = 0;

      for (var doc in widget.subscriptions) {
        final data = doc.data() as Map<String, dynamic>;
        final double price = (data['price'] ?? 0).toDouble();
        final String cycle = data['cycle'] ?? 'Mensile';
        
        final Timestamp? createdAtTs = data['createdAt'] as Timestamp?;
        final DateTime createdAt = createdAtTs?.toDate() ?? DateTime(2000);

        if (createdAt.isBefore(DateTime(now.year, now.month - i + 1, 1))) {
          monthTotal += cycle == 'Annuale' ? price / 12 : price;
        }
      }

      tempSpots.add(FlSpot((5 - i).toDouble(), monthTotal));
      if (monthTotal > tempMax) tempMax = monthTotal;
      
      if (i == 0) _currentSpend = monthTotal; 
    }

    setState(() {
      _spots = tempSpots;
      _monthLabels = tempLabels;
      
      double upperLimit = ((tempMax / 5).ceil()) * 5.0;
      
      if (upperLimit - tempMax < 1.0) upperLimit += 2.0;
      
      _maxSpend = upperLimit == 0 ? 15.0 : upperLimit; 
    });
  }

  @override
  Widget build(BuildContext context) {
    const double chartInterval = 5.0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40, height: 5,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey4, 
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Andamento nel Tempo', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)
            ),
          ),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(CupertinoIcons.graph_square_fill, color: CupertinoColors.activeBlue, size: 20),
                          SizedBox(width: 8),
                          Text('Ultimi 6 mesi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: CupertinoColors.systemGrey)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('€${_currentSpend.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
                      const Text('Spesa mensile attuale', style: TextStyle(fontSize: 13, color: CupertinoColors.systemGrey)),
                      
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: _maxSpend,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: chartInterval,
                              getDrawingHorizontalLine: (value) {
                                return const FlLine(color: Color(0xFFF0F0F0), strokeWidth: 1.5);
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 42,
                                  interval: chartInterval,
                                  getTitlesWidget: (value, meta) {
                                    if (value == 0) return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Text(
                                        '€${value.toInt()}',
                                        style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 11, fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.right,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 36,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= 0 && value.toInt() < _monthLabels.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 12.0),
                                        child: Text(
                                          _monthLabels[value.toInt()],
                                          style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            lineTouchData: LineTouchData(
                              getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                                return spotIndexes.map((index) {
                                  return TouchedSpotIndicatorData(
                                    const FlLine(color: CupertinoColors.activeBlue, strokeWidth: 2, dashArray: [4, 4]),
                                    FlDotData(
                                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                        radius: 5, color: Colors.white, strokeWidth: 3, strokeColor: CupertinoColors.activeBlue,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (touchedSpot) => const Color(0xFF333333),
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    return LineTooltipItem(
                                      '€${spot.y.toStringAsFixed(2)}',
                                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _spots,
                                isCurved: true,
                                curveSmoothness: 0.35,
                                color: CupertinoColors.activeBlue,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      CupertinoColors.activeBlue.withValues(alpha: 0.25),
                                      CupertinoColors.activeBlue.withValues(alpha: 0.0),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}