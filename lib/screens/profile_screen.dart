import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  late TextEditingController _nameController;
  bool _isLoading = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Errore nell'apertura della galleria");
    }
  }

  Future<void> _updateProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child('user_avatars/${user!.uid}.jpg');
        await storageRef.putFile(_imageFile!);
        final newPhotoUrl = await storageRef.getDownloadURL();
        await user?.updatePhotoURL(newPhotoUrl);
      }

      if (newName != user?.displayName) {
        await user?.updateDisplayName(newName);
      }

      await user?.reload(); 
      
      Fluttertoast.showToast(
        msg: "Profilo aggiornato! ✅",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: CupertinoColors.activeGreen,
        textColor: Colors.white,
      );
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Errore nell'aggiornamento.",
        backgroundColor: CupertinoColors.destructiveRed,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String photoUrl = user?.photoURL ?? '';
    final String displayName = user?.displayName ?? 'Utente';
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Profilo'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  
                  GestureDetector(
                    onTap: _pickImage,
                    child: Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(55),
                                child: _buildAvatar(initial, photoUrl),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007AFF),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader(
                    'INFORMAZIONI PUBBLICHE', 
                    CupertinoIcons.person_crop_circle, 
                    CupertinoColors.activeBlue
                  ),
                  _buildSectionContainer(
                    children: [
                      _buildEditableRow('Nome', _nameController),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildSectionHeader(
                    'SICUREZZA', 
                    CupertinoIcons.shield_fill, 
                    CupertinoColors.systemGreen
                  ),
                  _buildSectionContainer(
                    children: [
                      _buildReadOnlyRow('Email', user?.email ?? ''),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'I dati del tuo profilo sono sincronizzati con il tuo account Google e vengono utilizzati per personalizzare la tua esperienza su SubWallet. Puoi modificare il tuo nome e la tua foto del profilo, ma l\'email è protetta per motivi di sicurezza.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: CupertinoColors.systemGrey, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Indietro', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: const Color(0xFF007AFF),
                      disabledColor: const Color(0xFF007AFF).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _isLoading ? null : _updateProfile,
                      child: _isLoading 
                          ? const CupertinoActivityIndicator(color: Colors.white) 
                          : const Text('Salva', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String initial, String photoUrl) {
    if (_imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.cover);
    } else if (photoUrl.isNotEmpty) {
      return Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildInitials(initial));
    } else {
      return _buildInitials(initial);
    }
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGrey,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildEditableRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Inserisci nome',
                hintStyle: TextStyle(color: CupertinoColors.systemGrey4),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(CupertinoIcons.lock_fill, size: 14, color: CupertinoColors.systemGrey3),
        ],
      ),
    );
  }

  Widget _buildInitials(String initial) {
    return Container(
      color: const Color(0xFF007AFF).withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Text(
        initial, 
        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF007AFF))
      ),
    );
  }
}