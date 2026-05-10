import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
      await FirebaseAuth.instance.signOut();
      debugPrint("Logout effettuato con successo");
    } catch (e) {
      debugPrint("Errore durante il logout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(CupertinoIcons.person_fill, size: 50, color: Color(0xFF007AFF)),
          ),
          const SizedBox(height: 20),
          
          Text(
            user?.displayName ?? 'Utente Sconosciuto',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          
          Text(
            user?.email ?? '',
            style: const TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
          ),
          
          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              color: CupertinoColors.destructiveRed,
              borderRadius: BorderRadius.circular(14),
              onPressed: _signOut,
              child: const SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.square_arrow_right, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text('Disconnetti', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}