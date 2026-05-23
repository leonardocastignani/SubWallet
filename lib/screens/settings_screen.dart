import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'profile_screen.dart';
import 'reminders_screen.dart';
import 'monthly_report_screen.dart';
import 'budget_threshold_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint("Errore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
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
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildSectionHeader('ACCOUNT'),
                  _buildSectionContainer(
                    children: [
                      _buildSettingsTile(
                        icon: CupertinoIcons.person_fill, iconColor: CupertinoColors.activeBlue,
                        title: user?.displayName ?? 'Profilo', subtitle: user?.email ?? 'Accedi per gestire i tuoi dati',
                        isLast: true,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                      ),
                    ],
                  ),

                  _buildSectionHeader('NOTIFICHE'),
                  _buildSectionContainer(
                    children: [
                      _buildSettingsTile(
                        icon: CupertinoIcons.bell_fill, 
                        iconColor: CupertinoColors.systemOrange, 
                        title: 'Promemoria rinnovo', 
                        subtitle: 'Avvisa 1/3/7 giorni prima',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RemindersScreen())),
                      ),
                      _buildSettingsTile(
                        icon: CupertinoIcons.doc_text_fill, 
                        iconColor: CupertinoColors.systemYellow, 
                        title: 'Report mensile', 
                        subtitle: 'Riepilogo spese all\'inizio del mese',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MonthlyReportScreen())),
                      ),
                      _buildSettingsTile(
                        icon: CupertinoIcons.exclamationmark_triangle_fill, 
                        iconColor: CupertinoColors.destructiveRed, 
                        title: 'Soglia di budget', 
                        subtitle: 'Notifica se superi una soglia', 
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BudgetThresholdScreen())),
                        isLast: true
                      ),
                    ],
                  ),

                  _buildSectionHeader('DATI'),
                  _buildSectionContainer(
                    children: [
                      _buildSettingsTile(
                        icon: CupertinoIcons.arrow_down_doc_fill, 
                        iconColor: CupertinoColors.systemTeal, 
                        title: 'Importa / Esporta', 
                        subtitle: 'CSV o JSON · backup manuale'
                      ),
                      _buildSettingsTile(
                        icon: CupertinoIcons.cloud_fill, 
                        iconColor: CupertinoColors.activeBlue, 
                        title: 'Sync cloud', 
                        subtitle: 'Salvataggio automatico su database'
                      ),
                      _buildSettingsTile(
                        icon: CupertinoIcons.device_phone_portrait, 
                        iconColor: CupertinoColors.systemIndigo, 
                        title: 'Multi-dispositivo', 
                        subtitle: 'Gestione sessioni attive', 
                        isLast: true
                      ),
                    ],
                  ),

                  _buildSectionHeader('ASPETTO'),
                  _buildSectionContainer(
                    children: [
                      _buildSettingsTile(
                        icon: CupertinoIcons.moon_fill, 
                        iconColor: CupertinoColors.systemGrey, 
                        title: 'Tema', 
                        subtitle: 'Chiaro · scuro · sistema'
                      ),
                      _buildSettingsTile(
                        icon: CupertinoIcons.square_grid_2x2_fill, 
                        iconColor: CupertinoColors.systemGrey2, 
                        title: 'Visualizzazione default', 
                        subtitle: 'Lista · griglia · raggruppata', 
                        isLast: true
                      ),
                    ],
                  ),

                  _buildSectionHeader('PRIVACY'),
                  _buildSectionContainer(
                    children: [
                      _buildSettingsTile(
                        icon: CupertinoIcons.lock_fill, 
                        iconColor: CupertinoColors.systemGrey, 
                        title: 'Blocco app', 
                        subtitle: 'Face ID / Impronta / PIN'
                      ),
                      _buildSettingsTile(
                        icon: CupertinoIcons.eye_slash_fill, 
                        iconColor: CupertinoColors.systemGrey,
                        title: 'Modalità privata', 
                        subtitle: 'Nasconde importi nelle schermate', isLast: true,
                        trailing: CupertinoSwitch(value: false, onChanged: (bool value) {}, 
                        activeTrackColor: CupertinoColors.activeBlue),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero, color: CupertinoColors.destructiveRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), onPressed: _signOut,
                      child: const SizedBox(
                        height: 56,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.square_arrow_right, color: CupertinoColors.destructiveRed, size: 22),
                            SizedBox(width: 10),
                            Text('Disconnetti', style: TextStyle(color: CupertinoColors.destructiveRed, fontSize: 17, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(padding: const EdgeInsets.only(left: 32, bottom: 8, top: 16), child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CupertinoColors.systemGrey, letterSpacing: 1.2)));
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2))]), child: Column(children: children));
  }

  Widget _buildSettingsTile({required IconData icon, required Color iconColor, required String title, required String subtitle, Widget? trailing, bool isLast = false, VoidCallback? onTap}) {
    return Column(
      children: [
        CupertinoListTile(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), leadingSize: 40,
          leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)),
          title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          subtitle: Padding(padding: const EdgeInsets.only(top: 2), child: Text(subtitle, style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGrey))),
          trailing: trailing ?? const Icon(CupertinoIcons.chevron_right, color: CupertinoColors.systemGrey4, size: 20),
          onTap: onTap,
        ),
        if (!isLast) const Divider(height: 1, indent: 72, endIndent: 0, color: Color(0xFFF3F3F3)),
      ],
    );
  }
}