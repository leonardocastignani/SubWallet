import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  int _reminderDays = 3;

  @override
  void initState() {
    super.initState();
    _loadReminderDays();
  }

  Future<void> _loadReminderDays() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reminderDays = prefs.getInt('reminderDays') ?? 3;
    });
  }

  Future<void> _setReminderDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminderDays', days);
    setState(() {
      _reminderDays = days;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promemoria Rinnovo'),
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
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 32),
                
                _buildSectionHeader('AVVISA PRIMA DELLA SCADENZA'),
                _buildSectionContainer(
                  children: [
                    _buildCheckableTile(
                      title: '1 giorno prima', 
                      isSelected: _reminderDays == 1, 
                      onTap: () => _setReminderDays(1)
                    ),
                    _buildCheckableTile(
                      title: '3 giorni prima', 
                      isSelected: _reminderDays == 3, 
                      onTap: () => _setReminderDays(3)
                    ),
                    _buildCheckableTile(
                      title: '7 giorni prima', 
                      isSelected: _reminderDays == 7, 
                      onTap: () => _setReminderDays(7)
                    ),
                    _buildCheckableTile(
                      title: 'Nessuno', 
                      isSelected: _reminderDays == 0, 
                      isLast: true,
                      onTap: () => _setReminderDays(0)
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Riceverai una notifica push locale per ricordarti dei pagamenti imminenti. Assicurati di aver concesso i permessi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: CupertinoColors.systemGrey, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CupertinoColors.systemGrey, letterSpacing: 1.1)),
      ),
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }

  Widget _buildCheckableTile({required String title, required bool isSelected, required VoidCallback onTap, bool isLast = false}) {
    return Column(
      children: [
        CupertinoListTile(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          title: Text(title, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? const Color(0xFF007AFF) : Colors.black87)),
          trailing: isSelected ? const Icon(CupertinoIcons.checkmark_alt, color: Color(0xFF007AFF), size: 22) : const SizedBox(width: 22),
          onTap: onTap,
        ),
        if (!isLast) const Divider(height: 1, indent: 20, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}