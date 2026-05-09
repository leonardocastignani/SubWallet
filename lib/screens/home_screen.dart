import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/add_subscription_modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ]
              ),
              child: const Icon(
                CupertinoIcons.tray_arrow_down,
                size: 50,
                color: CupertinoColors.inactiveGray,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nessun abbonamento',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aggiungi il tuo primo abbonamento\nper iniziare a tracciarlo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15, 
                color: CupertinoColors.systemGrey,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddSubscriptionModal(context);
        },
        backgroundColor: const Color(0xFF007AFF), 
        foregroundColor: Colors.white,
        elevation: 4, 
        shape: const CircleBorder(),
        child: const Icon(CupertinoIcons.add, size: 28),
      ),
    );
  }
}