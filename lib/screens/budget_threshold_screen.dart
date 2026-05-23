import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetThresholdScreen extends StatefulWidget {
  const BudgetThresholdScreen({super.key});

  @override
  State<BudgetThresholdScreen> createState() => _BudgetThresholdScreenState();
}

class _BudgetThresholdScreenState extends State<BudgetThresholdScreen> {
  bool _isBudgetEnabled = false;
  double _budgetThreshold = 50.0;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBudgetEnabled = prefs.getBool('budgetAlertEnabled') ?? false;
      _budgetThreshold = prefs.getDouble('budgetThreshold') ?? 50.0;
    });
  }

  Future<void> _toggleBudget(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('budgetAlertEnabled', value);
    setState(() => _isBudgetEnabled = value);
  }

  Future<void> _updateThreshold(double value) async {
    setState(() => _budgetThreshold = value);
  }

  Future<void> _saveThreshold(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('budgetThreshold', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soglia di Budget'),
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
                
                const Padding(
                  padding: EdgeInsets.only(left: 32, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('CONTROLLO SPESA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CupertinoColors.systemGrey, letterSpacing: 1.1)),
                  ),
                ),
                
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      CupertinoListTile(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        title: const Text('Avviso superamento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                        trailing: CupertinoSwitch(
                          value: _isBudgetEnabled,
                          activeTrackColor: const Color(0xFF007AFF),
                          onChanged: _toggleBudget,
                        ),
                      ),
                      if (_isBudgetEnabled) ...[
                        const Divider(height: 1, indent: 20, color: CupertinoColors.systemGrey5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Limite mensile', style: TextStyle(fontSize: 15, color: CupertinoColors.systemGrey)),
                                  Text('€${_budgetThreshold.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: CupertinoColors.destructiveRed)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              CupertinoSlider(
                                value: _budgetThreshold,
                                min: 5.0,
                                max: 500.0,
                                divisions: 99,
                                activeColor: CupertinoColors.destructiveRed,
                                onChanged: _updateThreshold,
                                onChangeEnd: _saveThreshold,
                              ),
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Riceverai una notifica di avviso istantanea nel momento in cui l\'aggiunta di un nuovo abbonamento porterà la spesa totale mensile oltre il limite impostato.',
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
}