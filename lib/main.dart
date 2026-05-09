import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('Statistiche', style: TextStyle(color: Colors.grey))),
    const Center(child: Text('Impostazioni', style: TextStyle(color: Colors.grey))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SubWallet'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFF8AB9F8), height: 1.0), // Bordino in tinta
        ),
      ),
      body: _screens[_currentIndex],
      
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE5E5EA), width: 1.0)), 
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              activeIcon: Icon(CupertinoIcons.house_fill),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_bar),
              activeIcon: Icon(CupertinoIcons.chart_bar_fill),
              label: 'Statistiche',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings),
              activeIcon: Icon(CupertinoIcons.settings_solid),
              label: 'Impostazioni',
            ),
          ],
        ),
      ),
    );
  }
}

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
          debugPrint("Pulsante + premuto!");
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