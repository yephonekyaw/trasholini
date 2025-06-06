import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_client/models/user_profile_data_model.dart';
import 'package:flutter_client/providers/user_profile_provider.dart';

class ProfileUpdateModal extends ConsumerStatefulWidget {
  final UserProfile userProfile;

  const ProfileUpdateModal({Key? key, required this.userProfile})
    : super(key: key);

  @override
  ConsumerState<ProfileUpdateModal> createState() => _ProfileUpdateModalState();
}

class _ProfileUpdateModalState extends ConsumerState<ProfileUpdateModal> {
  late TextEditingController _nameController;
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.userProfile.displayName ?? '',
    );
    _nameController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onTextChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasChanges =
          _nameController.text.trim() !=
              (widget.userProfile.displayName ?? '') ||
          _selectedImagePath != null;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Failed to pick image: $e')),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_hasChanges) return;

    try {
      final displayName =
          _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim();

      await ref
          .read(userProfileProvider.notifier)
          .updateProfile(
            displayName: displayName,
            imagePath: _selectedImagePath,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Failed to update profile: $e')),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildProfileImage() {
    const double imageSize = 120;

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF4CAF50), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Profile Image
            ClipOval(
              child:
                  _selectedImagePath != null
                      ? Image.file(
                        File(_selectedImagePath!),
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                      )
                      : widget.userProfile.photoUrl != null
                      ? Image.network(
                        widget.userProfile.photoUrl!,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: imageSize,
                              height: imageSize,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                      )
                      : Container(
                        width: imageSize,
                        height: imageSize,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
            ),
            // Camera overlay
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileUpdateLoadingProvider);
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: keyboardHeight > 0 ? 40 : 80,
      ),
      child: Container(
        width: size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight:
              size.height - (keyboardHeight > 0 ? keyboardHeight + 100 : 160),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.edit, color: Color(0xFF4CAF50), size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed:
                          isLoading ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Profile Image
                _buildProfileImage(),

                const SizedBox(height: 16),

                // Tap to change image hint
                Text(
                  'Tap photo to change',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 24),

                // Name Input Field
                TextField(
                  controller: _nameController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Display Name',
                    labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF4CAF50),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF4CAF50),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _hasChanges ? _updateProfile() : null,
                ),

                const SizedBox(height: 32),

                // Update Button - Full Width with Enhanced Design
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient:
                          _hasChanges && !isLoading
                              ? const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                              : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow:
                          _hasChanges && !isLoading
                              ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF4CAF50,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : null,
                    ),
                    child: ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : (_hasChanges ? _updateProfile : null),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _hasChanges ? Colors.transparent : Colors.grey[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child:
                          isLoading
                              ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Updating...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.save_rounded, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _hasChanges ? 'Save Changes' : 'No Changes',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
