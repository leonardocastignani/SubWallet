import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class CurrencyLanguageScreen extends StatelessWidget {
  const CurrencyLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(provider.t('cur_lang_title')),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 32),
            
            _buildSectionHeader(provider.t('cur_header')),
            _buildSectionContainer(
              children: [
                _buildCheckableTile(
                  title: 'Euro (€)', 
                  isSelected: provider.currency == '€', 
                  onTap: () => provider.setCurrency('€')
                ),
                _buildCheckableTile(
                  title: 'Dollaro Statunitense (\$)', 
                  isSelected: provider.currency == '\$', 
                  onTap: () => provider.setCurrency('\$')
                ),
                _buildCheckableTile(
                  title: 'Sterlina Britannica (£)', 
                  isSelected: provider.currency == '£', 
                  isLast: true,
                  onTap: () => provider.setCurrency('£')
                ),
              ],
            ),

            const SizedBox(height: 32),

            _buildSectionHeader(provider.t('lang_header')),
            _buildSectionContainer(
              children: [
                _buildCheckableTile(
                  title: 'Italiano', 
                  isSelected: provider.language == 'Italiano', 
                  onTap: () => provider.setLanguage('Italiano')
                ),
                _buildCheckableTile(
                  title: 'English', 
                  isSelected: provider.language == 'English', 
                  isLast: true,
                  onTap: () => provider.setLanguage('English')
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                provider.t('cur_note'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGrey, height: 1.4),
              ),
            ),
          ],
        ),
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