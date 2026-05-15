import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/add_subscription_modal.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final prov = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('subscriptions').where('userId', isEqualTo: user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CupertinoActivityIndicator(radius: 16));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildEmptyState(prov);

          final subscriptions = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 88),
            itemCount: subscriptions.length,
            itemBuilder: (context, index) {
              final doc = subscriptions[index];
              final subData = doc.data() as Map<String, dynamic>;

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: CupertinoColors.destructiveRed, borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.centerRight, child: const Icon(CupertinoIcons.trash, color: Colors.white, size: 28),
                ),
                onDismissed: (direction) async {
                  final String serviceName = subData['serviceName'] ?? prov.t('unknown');
                  await FirestoreService().deleteSubscription(doc.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$serviceName ${prov.t('deleted')}'), backgroundColor: Colors.black87, behavior: SnackBarBehavior.floating),
                    );
                  }
                },
                child: _buildSubscriptionCard(subData, prov),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddSubscriptionModal(context),
        backgroundColor: const Color(0xFF007AFF), foregroundColor: Colors.white, elevation: 4, shape: const CircleBorder(),
        child: const Icon(CupertinoIcons.add, size: 28),
      ),
    );
  }

  Widget _buildEmptyState(SettingsProvider prov) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, spreadRadius: 2)]),
            child: const Icon(CupertinoIcons.tray_arrow_down, size: 50, color: CupertinoColors.inactiveGray),
          ),
          const SizedBox(height: 24),
          Text(prov.t('no_subs'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text(prov.t('no_subs_desc'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: CupertinoColors.systemGrey, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> data, SettingsProvider prov) {
    final String domain = data['domain'] ?? '';
    final double price = (data['price'] ?? 0.0).toDouble();
    final String cycle = prov.tCycle(data['cycle'] ?? 'Mensile');

    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 50, height: 50, color: CupertinoColors.systemGrey6,
              child: domain == 'custom'
                  ? Container(color: const Color(0xFF007AFF).withValues(alpha: 0.1), child: const Icon(CupertinoIcons.star_fill, color: Color(0xFF007AFF), size: 24))
                  : Image.network('https://www.google.com/s2/favicons?domain=$domain&sz=128', fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(CupertinoIcons.globe, color: CupertinoColors.systemGrey)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['serviceName'] ?? prov.t('unknown'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text(cycle, style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey)),
              ],
            ),
          ),
          Text('${prov.currency}${price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF007AFF))),
        ],
      ),
    );
  }
}