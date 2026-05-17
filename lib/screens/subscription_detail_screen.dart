import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class SubscriptionDetailScreen extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> subData;

  const SubscriptionDetailScreen({
    super.key,
    required this.docId,
    required this.subData,
  });

  @override
  Widget build(BuildContext context) {
    final String serviceName = subData['serviceName'] ?? 'Sconosciuto';
    final String domain = subData['domain'] ?? '';
    final double price = (subData['price'] ?? 0.0).toDouble();
    final String cycle = subData['cycle'] ?? 'Mensile';
    final String category = subData['category'] ?? 'Altro';
    final String paymentMethod = subData['paymentMethod'] ?? 'Altro';
    final String notes = subData['notes'] ?? '';
    
    DateTime renewalDate = DateTime.now();
    if (subData['nextRenewal'] is Timestamp) {
      renewalDate = (subData['nextRenewal'] as Timestamp).toDate();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(serviceName),
        automaticallyImplyLeading: false, 
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
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 16), 
                      
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: domain == 'custom'
                                ? Container(
                                    width: 70,
                                    height: 70,
                                    color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                                    child: const Icon(CupertinoIcons.star_fill, size: 36, color: Color(0xFF007AFF)),
                                  )
                                : Image.network(
                                    'https://www.google.com/s2/favicons?domain=$domain&sz=256',
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.contain,
                                    errorBuilder: (c, e, s) => const Icon(CupertinoIcons.globe, size: 40, color: CupertinoColors.systemGrey),
                                  ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8), 
                      
                      Text(
                        '€${price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1),
                      ),
                      const Text(
                        '/mese',
                        style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey, fontWeight: FontWeight.w500),
                      ),
                      
                      const SizedBox(height: 20), 
                      
                      _buildSectionHeader('INFORMAZIONI ABBONAMENTO'),
                      _buildSectionContainer(
                        children: [
                          _buildDetailRow('Ciclo', cycle),
                          const Divider(height: 1, indent: 16, color: Color(0xFFF3F3F3)),
                          _buildDetailRow('Categoria', category),
                          const Divider(height: 1, indent: 16, color: Color(0xFFF3F3F3)),
                          _buildDetailRow('Pagamento', paymentMethod),
                          const Divider(height: 1, indent: 16, color: Color(0xFFF3F3F3)),
                          _buildDetailRow('Rinnovo', '${renewalDate.day}/${renewalDate.month}/${renewalDate.year}'),
                        ],
                      ),
                      
                      const SizedBox(height: 16), 
                      
                      if (notes.trim().isNotEmpty) ...[
                        _buildSectionHeader('NOTE PERSONALIZZATE'),
                        _buildSectionContainer(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0), 
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  notes,
                                  style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24), 
                    ],
                  ),
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          color: CupertinoColors.systemGrey5,
                          borderRadius: BorderRadius.circular(12),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Indietro', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          color: CupertinoColors.destructiveRed,
                          borderRadius: BorderRadius.circular(12),
                          onPressed: () async {
                            await FirestoreService().deleteSubscription(docId);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$serviceName eliminato'),
                                  backgroundColor: Colors.black87,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Elimina', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 6, top: 4), 
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CupertinoColors.systemGrey, letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF007AFF))),
        ],
      ),
    );
  }
}