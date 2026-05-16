import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;

  final List<Widget> _screens = [
    const StatisticsScreen(),
    const HomeScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    NotificationService().requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SubWallet'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFF8AB9F8), height: 1.0),
        ),
      ),
      body: _screens[_currentIndex],
      
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE5E5EA), width: 1.0)), 
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_bar),
              activeIcon: Icon(CupertinoIcons.chart_bar_fill),
              label: context.watch<SettingsProvider>().t('tab_stats'),
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              activeIcon: Icon(CupertinoIcons.house_fill),
              label: context.watch<SettingsProvider>().t('tab_home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings),
              activeIcon: Icon(CupertinoIcons.settings_solid),
              label: context.watch<SettingsProvider>().t('tab_settings'),
            ),
          ],
        ),
      ),
    );
  }
}