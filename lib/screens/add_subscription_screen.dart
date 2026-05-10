import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/firestore_service.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final String serviceName;
  final String domain;

  const AddSubscriptionScreen({
    super.key,
    required this.serviceName,
    required this.domain,
  });

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  int _selectedCycleIndex = 0;
  DateTime _selectedDate = DateTime.now();
  
  String _selectedPaymentMethod = 'PayPal';
  bool _isLoading = false;

  final List<String> _paymentMethods = [
    'PayPal',
    'Carta di Credito',
    'Bonifico',
    'Ricarica Postepay',
    'Apple Pay',
    'Google Pay',
    'Altro'
  ];

  @override
  void dispose() {
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveSubscription() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final double price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;
    
    final String cycle = _selectedCycleIndex == 0 ? 'Mensile' : 'Annuale';

    final bool success = await FirestoreService().addSubscription(
      serviceName: widget.serviceName,
      domain: widget.domain,
      price: price,
      cycle: cycle,
      paymentMethod: _selectedPaymentMethod,
      nextRenewal: _selectedDate,
      notes: _notesController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.serviceName} aggiunto con successo!'),
          backgroundColor: CupertinoColors.activeGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore durante il salvataggio.'),
          backgroundColor: CupertinoColors.destructiveRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettagli Abbonamento'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            Hero(
              tag: 'logo_${widget.serviceName}',
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    'https://www.google.com/s2/favicons?domain=${widget.domain}&sz=256',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(CupertinoIcons.globe, size: 40, color: CupertinoColors.systemGrey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.serviceName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _buildSection(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Text('Costo', style: TextStyle(fontSize: 17)),
                      const Spacer(),
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0.00',
                          ),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('€', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
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
                      const Text('Pagamento', style: TextStyle(fontSize: 17)),
                      const SizedBox(width: 16),
                      
                      Flexible(
                        child: PopupMenuButton<String>(
                          initialValue: _selectedPaymentMethod,
                          color: Colors.white,
                          surfaceTintColor: Colors.white,
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          position: PopupMenuPosition.under,
                          onSelected: (String newValue) {
                            setState(() {
                              _selectedPaymentMethod = newValue;
                            });
                          },
                          itemBuilder: (BuildContext context) {
                            return _paymentMethods.map((String method) {
                              return PopupMenuItem<String>(
                                value: method,
                                height: 44,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        method,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _selectedPaymentMethod == method ? const Color(0xFF007AFF) : Colors.black87,
                                          fontWeight: _selectedPaymentMethod == method ? FontWeight.w600 : FontWeight.w400,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (_selectedPaymentMethod == method)
                                      const Icon(CupertinoIcons.checkmark_alt, color: Color(0xFF007AFF), size: 18),
                                  ],
                                ),
                              );
                            }).toList();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    _selectedPaymentMethod,
                                    style: const TextStyle(color: Color(0xFF007AFF), fontSize: 17, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(CupertinoIcons.chevron_up_chevron_down, size: 14, color: CupertinoColors.systemGrey2),
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
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _selectedDate = picked);
                        },
                        child: Text(
                          "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                        ),
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
                      const Text('Note', style: TextStyle(fontSize: 17)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Dettagli aggiuntivi...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
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
                      padding: EdgeInsets.zero,
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Annulla', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: const Color(0xFF007AFF),
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _isLoading ? null : _saveSubscription,
                      child: _isLoading 
                          ? const CupertinoActivityIndicator(color: Colors.white) 
                          : const Text('Salva', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }
}