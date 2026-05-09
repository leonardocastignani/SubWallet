import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const SubWalletApp());
}

class SubWalletApp extends StatelessWidget {
  const SubWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubWallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007AFF)),
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        splashColor: const Color(0xFF007AFF).withValues(alpha: 0.15),
        highlightColor: Colors.transparent,
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF9FC9FF),
          elevation: 0, 
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF003366),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF007AFF),
          unselectedItemColor: CupertinoColors.inactiveGray,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 10),
        ),
      ),
      home: const MainScreen(),
    );
  }
}