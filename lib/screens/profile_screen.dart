import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

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
    final prov = context.read<SettingsProvider>();
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: prov.t('gallery_error'));
    }
  }

  Future<void> _updateProfile() async {
    final prov = context.read<SettingsProvider>();
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
        msg: prov.t('profile_updated'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: CupertinoColors.activeGreen,
        textColor: Colors.white,
      );
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: prov.t('update_error'),
        backgroundColor: CupertinoColors.destructiveRed,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SettingsProvider>();
    
    final String photoUrl = user?.photoURL ?? '';
    final String displayName = user?.displayName ?? 'Utente';
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(prov.t('profile')),
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
                    prov.t('public_info'), 
                    CupertinoIcons.person_crop_circle, 
                    CupertinoColors.activeBlue
                  ),
                  _buildSectionContainer(
                    children: [
                      _buildEditableRow(prov.t('name_label'), _nameController, prov.t('insert_name')),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildSectionHeader(
                    prov.t('security'), 
                    CupertinoIcons.shield_fill, 
                    CupertinoColors.systemGreen
                  ),
                  _buildSectionContainer(
                    children: [
                      _buildReadOnlyRow(prov.t('email'), user?.email ?? ''),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      prov.t('profile_desc'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGrey, height: 1.4),
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
                      child: Text(prov.t('back'), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
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
                          : Text(prov.t('save'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildEditableRow(String label, TextEditingController controller, String hint) {
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
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: CupertinoColors.systemGrey4),
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