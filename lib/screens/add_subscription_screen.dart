import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final String serviceName;
  final String domain;
  final bool isCustom; 

  const AddSubscriptionScreen({super.key, required this.serviceName, required this.domain, this.isCustom = false});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final TextEditingController _nameController = TextEditingController(); 
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  int _selectedCycleIndex = 0;
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMethod = 'PayPal';
  String _selectedCategory = 'Intrattenimento';
  bool _isLoading = false;

  final List<String> _paymentMethods = ['PayPal', 'Carta di Credito', 'Bonifico', 'Postepay', 'Apple Pay', 'Google Pay', 'Altro'];
  final List<String> _categories = ['Intrattenimento', 'Produttività', 'Gaming', 'Informazione', 'Salute e Sport', 'Utility', 'Altro'];

  @override
  void initState() {
    super.initState();
    if (!widget.isCustom) _nameController.text = widget.serviceName;
  }

  @override
  void dispose() {
    _nameController.dispose(); _priceController.dispose(); _notesController.dispose();
    super.dispose();
  }

  bool _canSave() {
    if (_isLoading) return false;
    if (widget.isCustom && _nameController.text.trim().isEmpty) return false;
    return true;
  }

  Future<void> _saveSubscription() async {
    if (!_canSave()) return;
    final String finalServiceName = widget.isCustom ? _nameController.text.trim() : widget.serviceName;
    setState(() => _isLoading = true);

    final double price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;
    final String cycle = _selectedCycleIndex == 0 ? 'Mensile' : 'Annuale';

    final bool success = await FirestoreService().addSubscription(
      serviceName: finalServiceName, domain: widget.isCustom ? 'custom' : widget.domain, 
      price: price, cycle: cycle, paymentMethod: _selectedPaymentMethod,
      category: _selectedCategory, nextRenewal: _selectedDate, notes: _notesController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final reminderDays = prefs.getInt('reminderDays') ?? 3;
        if (reminderDays > 0) {
          await NotificationService().scheduleRenewalReminder(
            serviceName: finalServiceName,
            price: price,
            renewalDate: _selectedDate,
            reminderDays: reminderDays,
            currency: '€',
          );
        }
      } catch (e) {
        debugPrint("Errore durante la programmazione della notifica: $e");
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$finalServiceName aggiunto!'), backgroundColor: CupertinoColors.activeGreen, behavior: SnackBarBehavior.floating));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dettagli Abbonamento'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Hero(
              tag: widget.isCustom ? 'logo_custom' : 'logo_${widget.serviceName}',
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: widget.isCustom 
                    ? Container(width: 60, height: 60, color: const Color(0xFF007AFF).withValues(alpha: 0.1), child: const Icon(CupertinoIcons.star_fill, size: 34, color: Color(0xFF007AFF)))
                    : Image.network('https://www.google.com/s2/favicons?domain=${widget.domain}&sz=256', width: 60, height: 60, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(CupertinoIcons.globe, size: 40, color: CupertinoColors.systemGrey)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: widget.isCustom
                  ? CupertinoTextField(
                      controller: _nameController, textAlign: TextAlign.center,
                      placeholder: 'Nome (es. Palestra)', placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 20),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(color: CupertinoColors.systemGrey6, borderRadius: BorderRadius.circular(12), border: Border.all(color: _nameController.text.trim().isEmpty ? CupertinoColors.destructiveRed.withValues(alpha: 0.6) : Colors.transparent, width: 1.5)),
                      onChanged: (value) => setState(() {}),
                    )
                  : Text(widget.serviceName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),

            _buildSection(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Text('Costo', style: TextStyle(fontSize: 17)), const Spacer(),
                      Expanded(child: TextField(controller: _priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), textAlign: TextAlign.right, decoration: const InputDecoration(border: InputBorder.none, hintText: '0.00'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
                      const SizedBox(width: 4), const Text('€', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ciclo', style: TextStyle(fontSize: 17)),
                      CupertinoSlidingSegmentedControl<int>(
                        groupValue: _selectedCycleIndex,
                        children: const {
                          0: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Mensile')),
                          1: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Annuale')),
                        },
                        onValueChanged: (int? v) => setState(() => _selectedCycleIndex = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            _buildSection(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Categoria', style: TextStyle(fontSize: 17)), const SizedBox(width: 16),
                      Flexible(
                        child: PopupMenuButton<String>(
                          initialValue: _selectedCategory, color: Colors.white, surfaceTintColor: Colors.white, elevation: 6, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), position: PopupMenuPosition.under,
                          onSelected: (String newValue) => setState(() => _selectedCategory = newValue),
                          itemBuilder: (BuildContext context) {
                            return _categories.map((String category) {
                              return PopupMenuItem<String>(
                                value: category, height: 44,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(category, style: TextStyle(fontSize: 16, color: _selectedCategory == category ? const Color(0xFF007AFF) : Colors.black87, fontWeight: _selectedCategory == category ? FontWeight.w600 : FontWeight.w400), overflow: TextOverflow.ellipsis)),
                                    if (_selectedCategory == category) const Icon(CupertinoIcons.checkmark_alt, color: Color(0xFF007AFF), size: 18),
                                  ],
                                ),
                              );
                            }).toList();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(child: Text(_selectedCategory, style: const TextStyle(color: Color(0xFF007AFF), fontSize: 17, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right)),
                                const SizedBox(width: 4), const Icon(CupertinoIcons.chevron_up_chevron_down, size: 14, color: CupertinoColors.systemGrey2),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pagamento', style: TextStyle(fontSize: 17)), const SizedBox(width: 16),
                      Flexible(
                        child: PopupMenuButton<String>(
                          initialValue: _selectedPaymentMethod, color: Colors.white, surfaceTintColor: Colors.white, elevation: 6, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), position: PopupMenuPosition.under,
                          onSelected: (String newValue) => setState(() => _selectedPaymentMethod = newValue),
                          itemBuilder: (BuildContext context) {
                            return _paymentMethods.map((String method) {
                              return PopupMenuItem<String>(
                                value: method, height: 44,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(method, style: TextStyle(fontSize: 16, color: _selectedPaymentMethod == method ? const Color(0xFF007AFF) : Colors.black87, fontWeight: _selectedPaymentMethod == method ? FontWeight.w600 : FontWeight.w400), overflow: TextOverflow.ellipsis)),
                                    if (_selectedPaymentMethod == method) const Icon(CupertinoIcons.checkmark_alt, color: Color(0xFF007AFF), size: 18),
                                  ],
                                ),
                              );
                            }).toList();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(child: Text(_selectedPaymentMethod, style: const TextStyle(color: Color(0xFF007AFF), fontSize: 17, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right)),
                                const SizedBox(width: 4), const Icon(CupertinoIcons.chevron_up_chevron_down, size: 14, color: CupertinoColors.systemGrey2),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Prossimo rinnovo', style: TextStyle(fontSize: 17)),
                      TextButton(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
                          if (picked != null) setState(() => _selectedDate = picked);
                        },
                        child: Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            _buildSection(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Note', style: TextStyle(fontSize: 17)), const SizedBox(height: 8),
                      TextField(
                        controller: _notesController, maxLines: 2,
                        decoration: InputDecoration(hintText: 'Dettagli aggiuntivi...', hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14), filled: true, fillColor: const Color(0xFFF9F9F9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero, color: CupertinoColors.systemGrey5, borderRadius: BorderRadius.circular(12),
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Annulla', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero, color: const Color(0xFF007AFF), disabledColor: const Color(0xFF007AFF).withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12),
                      onPressed: _canSave() ? _saveSubscription : null,
                      child: _isLoading ? const CupertinoActivityIndicator(color: Colors.white) : const Text('Salva', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(children: children));
  }
}