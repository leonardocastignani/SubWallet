import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/settings_provider.dart';
import 'profile_screen.dart';
import 'reminders_screen.dart';

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
    final prov = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 1),
            _buildSectionHeader(prov.t('sec_account')),
            _buildSectionContainer(
              children: [
                _buildSettingsTile(
                  icon: CupertinoIcons.person_fill, iconColor: CupertinoColors.activeBlue,
                  title: user?.displayName ?? prov.t('profile'), subtitle: user?.email ?? prov.t('profile_sub'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                ),
                _buildSettingsTile(
                  icon: CupertinoIcons.money_euro,
                  iconColor: CupertinoColors.systemGreen,
                  title: prov.t('cur_lang'), subtitle: prov.t('cur_lang_sub'), isLast: true,
                  onTap: () {
                    Fluttertoast.showToast(
                      msg: "Impostazione momentaneamente non disponibile 🚧",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: const Color(0xFF333333),
                      textColor: Colors.white,
                    );
                  },
                ),
              ],
            ),

            _buildSectionHeader(prov.t('sec_notif')),
            _buildSectionContainer(
              children: [
                _buildSettingsTile(
                  icon: CupertinoIcons.bell_fill, iconColor: CupertinoColors.systemOrange, 
                  title: prov.t('reminders'), subtitle: prov.t('reminders_sub'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RemindersScreen())),
                ),
                _buildSettingsTile(icon: CupertinoIcons.doc_text_fill, iconColor: CupertinoColors.systemYellow, title: prov.t('report'), subtitle: prov.t('report_sub')),
                _buildSettingsTile(icon: CupertinoIcons.exclamationmark_triangle_fill, iconColor: CupertinoColors.destructiveRed, title: prov.t('budget'), subtitle: prov.t('budget_sub'), isLast: true),
              ],
            ),

            _buildSectionHeader(prov.t('sec_data')),
            _buildSectionContainer(
              children: [
                _buildSettingsTile(icon: CupertinoIcons.arrow_down_doc_fill, iconColor: CupertinoColors.systemTeal, title: prov.t('import_export'), subtitle: prov.t('import_export_sub')),
                _buildSettingsTile(icon: CupertinoIcons.cloud_fill, iconColor: CupertinoColors.activeBlue, title: prov.t('cloud_sync'), subtitle: prov.t('cloud_sync_sub')),
                _buildSettingsTile(icon: CupertinoIcons.device_phone_portrait, iconColor: CupertinoColors.systemIndigo, title: prov.t('multi_dev'), subtitle: prov.t('multi_dev_sub'), isLast: true),
              ],
            ),

            _buildSectionHeader(prov.t('sec_appearance')),
            _buildSectionContainer(
              children: [
                _buildSettingsTile(icon: CupertinoIcons.moon_fill, iconColor: CupertinoColors.systemGrey, title: prov.t('theme'), subtitle: prov.t('theme_sub')),
                _buildSettingsTile(icon: CupertinoIcons.square_grid_2x2_fill, iconColor: CupertinoColors.systemGrey2, title: prov.t('def_view'), subtitle: prov.t('def_view_sub'), isLast: true),
              ],
            ),

            _buildSectionHeader(prov.t('sec_privacy')),
            _buildSectionContainer(
              children: [
                _buildSettingsTile(icon: CupertinoIcons.lock_fill, iconColor: CupertinoColors.systemGrey, title: prov.t('app_lock'), subtitle: prov.t('app_lock_sub')),
                _buildSettingsTile(
                  icon: CupertinoIcons.eye_slash_fill, iconColor: CupertinoColors.systemGrey,
                  title: prov.t('priv_mode'), subtitle: prov.t('priv_mode_sub'), isLast: true,
                  trailing: CupertinoSwitch(value: false, onChanged: (bool value) {}, activeTrackColor: CupertinoColors.activeBlue),
                ),
              ],
            ),

            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoButton(
                padding: EdgeInsets.zero, color: CupertinoColors.destructiveRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), onPressed: _signOut,
                child: SizedBox(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.square_arrow_right, color: CupertinoColors.destructiveRed, size: 22),
                      const SizedBox(width: 10),
                      Text(prov.t('logout'), style: const TextStyle(color: CupertinoColors.destructiveRed, fontSize: 17, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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