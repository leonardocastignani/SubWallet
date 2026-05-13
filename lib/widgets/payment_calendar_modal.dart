import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showPaymentCalendarModal(BuildContext context, List<QueryDocumentSnapshot> subscriptions) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _PaymentCalendarModalContent(subscriptions: subscriptions),
  );
}

class _PaymentCalendarModalContent extends StatefulWidget {
  final List<QueryDocumentSnapshot> subscriptions;

  const _PaymentCalendarModalContent({required this.subscriptions});

  @override
  State<_PaymentCalendarModalContent> createState() => _PaymentCalendarModalContentState();
}

class _PaymentCalendarModalContentState extends State<_PaymentCalendarModalContent> {
  List<Map<String, dynamic>> _upcomingPayments = [];
  double _upcomingTotal = 0;

  final Map<String, Color> categoryColors = {
    'Intrattenimento': const Color(0xFF8EBBFF),
    'Produttività': const Color(0xFFC9A2FF),
    'Gaming': const Color(0xFFFF9F9F),
    'Informazione': const Color(0xFF86E3E9),
    'Salute e Sport': const Color(0xFFFFD18D),
    'Utility': const Color(0xFFC7E298),
    'Altro': CupertinoColors.systemGrey4,
  };

  @override
  void initState() {
    super.initState();
    _calculateUpcomingPayments();
  }

  String _getMonthShort(int month) {
    const months = ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'];
    return months[month - 1];
  }

  DateTime _getActualNextRenewal(DateTime pastDate, String cycle) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime next = pastDate;

    while (next.isBefore(today)) {
      if (cycle == 'Annuale') {
        next = DateTime(next.year + 1, next.month, next.day);
      } else {
        next = DateTime(next.year, next.month + 1, next.day);
      }
    }
    return next;
  }

  void _calculateUpcomingPayments() {
    List<Map<String, dynamic>> tempPayments = [];
    double tempTotal = 0;
    
    DateTime now = DateTime.now();
    DateTime limitDate = now.add(const Duration(days: 31));

    for (var doc in widget.subscriptions) {
      final data = doc.data() as Map<String, dynamic>;
      final String serviceName = data['serviceName'] ?? 'Sconosciuto';
      final double price = (data['price'] ?? 0).toDouble();
      final String cycle = data['cycle'] ?? 'Mensile';
      final String category = data['category'] ?? 'Altro';
      
      final Timestamp? renewalTs = data['nextRenewal'] as Timestamp?;
      final DateTime originalRenewal = renewalTs?.toDate() ?? DateTime.now();

      DateTime actualRenewal = _getActualNextRenewal(originalRenewal, cycle);

      if (actualRenewal.isBefore(limitDate) || actualRenewal.isAtSameMomentAs(limitDate)) {
        tempPayments.add({
          'serviceName': serviceName,
          'price': price,
          'date': actualRenewal,
          'category': category,
        });
        tempTotal += price;
      }
    }

    tempPayments.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    setState(() {
      _upcomingPayments = tempPayments;
      _upcomingTotal = tempTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              'Calendario Pagamenti', 
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
                          Icon(CupertinoIcons.calendar, color: CupertinoColors.systemOrange, size: 20),
                          SizedBox(width: 8),
                          Text('Prossimi 30 giorni', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: CupertinoColors.systemGrey)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('€${_upcomingTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
                      Text('${_upcomingPayments.length} pagamenti in uscita a breve', style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGrey)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                const Row(
                  children: [
                    Icon(CupertinoIcons.clock, color: CupertinoColors.systemOrange, size: 18), // <--- CAMBIATA ICONA QUI
                    SizedBox(width: 6),
                    Text('TIMELINE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CupertinoColors.systemGrey, letterSpacing: 1.2)),
                  ],
                ),
                const SizedBox(height: 12),

                if (_upcomingPayments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: Text('Nessun pagamento in programma.', style: TextStyle(color: CupertinoColors.systemGrey))),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: _upcomingPayments.map((payment) {
                        final bool isLast = payment == _upcomingPayments.last;
                        final DateTime date = payment['date'];
                        final String name = payment['serviceName'];
                        final double price = payment['price'];
                        final Color color = categoryColors[payment['category']] ?? CupertinoColors.systemGrey;

                        return Column(
                          children: [
                            CupertinoListTile(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              leadingSize: 48,
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${date.day}', 
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color, height: 1.0)
                                    ),
                                    Text(
                                      _getMonthShort(date.month), 
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color.withValues(alpha: 0.7), letterSpacing: 0.5)
                                    ),
                                  ],
                                ),
                              ),
                              title: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              subtitle: Text(payment['category'], style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGrey)),
                              trailing: Text('€${price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                            if (!isLast) const Divider(height: 1, indent: 80, color: Color(0xFFF3F3F3)),
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