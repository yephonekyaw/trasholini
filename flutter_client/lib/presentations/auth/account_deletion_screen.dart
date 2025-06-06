import 'package:flutter/material.dart';
import 'package:flutter_client/providers/danger_service_provider.dart';
import 'package:flutter_client/providers/google_auth_provider.dart';
import 'package:flutter_client/services/apis/danger_deletion_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AccountDeletionPage extends ConsumerStatefulWidget {
  const AccountDeletionPage({super.key});

  @override
  ConsumerState<AccountDeletionPage> createState() =>
      _AccountDeletionPageState();
}

class _AccountDeletionPageState extends ConsumerState<AccountDeletionPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  String _userEmail = '';
  String _confirmText = '';
  final _emailController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset state and load preview
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resetAllDangerStatesActionProvider)();
      ref.read(deletionPreviewProvider.notifier).loadPreview();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF3E0),
            Color(0xFFFFE0B2),
          ], // Orange gradient for warning theme
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (_currentStep == 0) {
                      context.pop();
                    } else {
                      _previousStep();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      _currentStep == 0
                          ? Icons.close_rounded
                          : Icons.arrow_back_ios_new_rounded,
                      color: const Color(0xFFE65100),
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delete Account',
                      style: TextStyle(
                        color: Color(0xFFBF360C),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentStep == 0
                          ? 'Review what will be deleted'
                          : 'Confirm account deletion',
                      style: TextStyle(
                        color: const Color(0xFFE65100).withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Step indicators
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                ...List.generate(2, (index) {
                  final isActive = index <= _currentStep;
                  final isWarning = index == 0;

                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color:
                                  isActive
                                      ? (isWarning
                                          ? const Color(0xFFFF9800)
                                          : const Color(0xFFE53935))
                                      : const Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        if (index < 1) const SizedBox(width: 8),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildPreviewStep(), _buildConfirmationStep()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewStep() {
    return Consumer(
      builder: (context, ref, child) {
        final previewState = ref.watch(deletionPreviewProvider);
        final preview = previewState.preview;
        final isLoading = previewState.isLoading;
        final error = previewState.error;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[50]!, Colors.orange[100]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[600],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.preview,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Deletion Preview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Review what will be permanently deleted',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (isLoading) ...[
                _buildLoadingCard(),
              ] else if (error != null) ...[
                _buildErrorCard(error),
              ] else if (preview != null) ...[
                // Total items card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red[50]!, Colors.pink[50]!],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Items to Delete',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[600],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${preview.estimatedTotalItems}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (preview.estimatedTotalItems == 0) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.green[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No data found to delete. Your account appears to be empty.',
                                  style: TextStyle(color: Colors.green[800]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (preview.estimatedTotalItems > 0) ...[
                  const SizedBox(height: 20),

                  // Account Data
                  if (preview.firestoreCollections.isNotEmpty) ...[
                    _buildDataCard(
                      'Account Data',
                      Icons.person,
                      Colors.blue,
                      preview.firestoreCollections,
                      {
                        'profiles': 'Profile information and settings',
                        'disposal_history': 'All scan history and eco-points',
                        'available_bins': 'Bin preferences and settings',
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Uploaded Files
                  if (preview.cloudStorageFolders.isNotEmpty) ...[
                    _buildDataCard(
                      'Uploaded Files',
                      Icons.cloud,
                      Colors.purple,
                      preview.cloudStorageFolders,
                      {
                        'disposal_images': 'All your scan photos',
                        'profile_images': 'Profile pictures and avatars',
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Warning
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          color: Colors.red[600],
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'This action cannot be undone',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'All your eco-warrior progress, scan history, and uploaded images will be permanently removed from our servers.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red[700],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          preview != null && preview.estimatedTotalItems > 0
                              ? _nextStep
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: Text(
                        preview != null && preview.estimatedTotalItems > 0
                            ? 'Continue'
                            : 'Nothing',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfirmationStep() {
    return Consumer(
      builder: (context, ref, child) {
        final deletionState = ref.watch(userDeletionProvider);
        final isDeleting = deletionState.isDeleting;
        final isEmailValid =
            _userEmail.isNotEmpty &&
            RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_userEmail);
        final isConfirmValid = _confirmText == 'DELETE';
        final canDelete = isEmailValid && isConfirmValid && !isDeleting;

        // Listen for deletion completion
        ref.listen<UserDeletionState>(userDeletionProvider, (previous, next) {
          if (next.deletionCompleted) {
            if (next.deletionResponse?.success == true) {
              _handleDeletionSuccess(next.deletionResponse!);
            } else {
              _showErrorSnackBar(next.error ?? 'Unknown error occurred');
            }
          }
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red[50]!, Colors.pink[50]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delete Profile',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Confirm your identity to proceed',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Warning Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning, color: Colors.red[600], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Warning: This action is permanent!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWarningItem('All your eco-points will be lost'),
                        const SizedBox(height: 8),
                        _buildWarningItem('Your scan history will be deleted'),
                        const SizedBox(height: 8),
                        _buildWarningItem('Your account cannot be recovered'),
                        const SizedBox(height: 8),
                        _buildWarningItem(
                          'You\'ll lose your eco-warrior progress',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Email verification
              Text(
                'Enter your email to verify:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                enabled: !isDeleting,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() => _userEmail = value.trim());
                },
                decoration: InputDecoration(
                  hintText: 'your.email@example.com',
                  prefixIcon: Icon(
                    isEmailValid ? Icons.check_circle : Icons.email,
                    color: isEmailValid ? Colors.green : Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                  ),
                  errorText:
                      _userEmail.isNotEmpty && !isEmailValid
                          ? 'Please enter a valid email address'
                          : null,
                ),
              ),

              const SizedBox(height: 20),

              // Confirmation Input
              Text(
                'Type "DELETE" to confirm:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                enabled: !isDeleting,
                onChanged: (value) {
                  setState(() => _confirmText = value);
                },
                decoration: InputDecoration(
                  hintText: 'Type DELETE here',
                  prefixIcon: Icon(
                    isConfirmValid ? Icons.check_circle : Icons.edit,
                    color: isConfirmValid ? Colors.green : Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red[600]!, width: 2),
                  ),
                ),
              ),

              if (deletionState.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          deletionState.error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isDeleting ? null : _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          canDelete ? () => _handleDeleteProfile() : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            canDelete ? Colors.red[600] : Colors.grey[300],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          isDeleting
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
                                  const Text('Deleting...'),
                                ],
                              )
                              : const Text(
                                'Delete Forever',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing your account data...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error loading data',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(error, style: TextStyle(color: Colors.red[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(
    String title,
    IconData icon,
    Color color,
    Map<String, int> data,
    Map<String, String> descriptions,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...data.entries.map((entry) {
            final description = descriptions[entry.key] ?? entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${entry.value}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.red[600],
            height: 1.4,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.red[600], height: 1.4),
          ),
        ),
      ],
    );
  }

  Future<void> _handleDeleteProfile() async {
    try {
      await ref
          .read(userDeletionProvider.notifier)
          .deleteAllUserData(userEmail: _userEmail, forceDelete: false);
    } catch (e) {
      _showErrorSnackBar('Failed to initiate deletion: $e');
    }
  }

  Future<void> _handleDeletionSuccess(UserDeletionResponse response) async {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.eco_outlined, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Profile deleted. Thank you for being an eco-warrior!',
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Sign out user after successful deletion
    try {
      ref.read(googleAuthProvider.notifier).signOut();
      if (mounted) {
        context.goNamed('signin');
      }
    } catch (e) {
      // If sign out fails, still navigate to signin
      if (mounted) {
        context.goNamed('signin');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
