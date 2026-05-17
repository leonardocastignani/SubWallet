import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../screens/add_subscription_screen.dart';

void showAddSubscriptionModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Colors.white,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 8, top: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Seleziona servizio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                      IconButton(icon: const Icon(CupertinoIcons.clear_thick_circled, color: CupertinoColors.systemGrey3, size: 26), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE5E5EA)),
                
                Flexible(
                  child: ListView(
                    shrinkWrap: true, physics: const BouncingScrollPhysics(),
                    children: [
                      _buildServiceTile(context, 'Netflix', 'netflix.com'),
                      _buildServiceTile(context, 'Spotify', 'spotify.com'),
                      _buildServiceTile(context, 'Amazon Prime', 'amazonprime.com'),
                      _buildServiceTile(context, 'Disney+', 'disneyplus.com'),
                      _buildServiceTile(context, 'Apple One', 'apple.com'),
                      _buildServiceTile(context, 'PlayStation Plus', 'playstation.com'),
                      const Divider(height: 1, color: Color(0xFFE5E5EA)),
                      _buildCustomServiceTile(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildServiceTile(BuildContext context, String name, String domain) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    leading: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 44, height: 44, color: CupertinoColors.systemGrey6,
        child: Image.network('https://www.google.com/s2/favicons?domain=$domain&sz=128', fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(CupertinoIcons.globe, color: CupertinoColors.systemGrey)),
      ),
    ),
    title: Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
    trailing: const Icon(CupertinoIcons.add_circled, color: Color(0xFF007AFF), size: 24),
    onTap: () {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddSubscriptionScreen(serviceName: name, domain: domain)));
    },
  );
}

Widget _buildCustomServiceTile(BuildContext context) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF007AFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(CupertinoIcons.pen, color: Color(0xFF007AFF))),
    title: const Text('Crea personalizzato', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF007AFF))),
    subtitle: const Text('Aggiungi un servizio non in lista', style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
    onTap: () {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSubscriptionScreen(serviceName: '', domain: '', isCustom: true)));
    },
  );
}