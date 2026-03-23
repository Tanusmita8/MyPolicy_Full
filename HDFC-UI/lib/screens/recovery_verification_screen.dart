import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import 'recovery_otp_screen.dart';


enum RecoveryMode { forgotPassword, getCustomerId }

class RecoveryVerificationScreen extends StatefulWidget {
  final RecoveryMode mode;
  const RecoveryVerificationScreen({super.key, this.mode = RecoveryMode.forgotPassword});

  @override
  State<RecoveryVerificationScreen> createState() => _RecoveryVerificationScreenState();
}


class _RecoveryVerificationScreenState extends State<RecoveryVerificationScreen> {
  final _customerIdController = TextEditingController();
  final _contactController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _handleVerify() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          final cleanId = _customerIdController.text.trim().toUpperCase();
          final cleanContact = _contactController.text.trim().toLowerCase();

          debugPrint('DEBUG: Mode: \\${widget.mode}');
          debugPrint('DEBUG: Customer ID: "$cleanId" (len: \\${cleanId.length})');
          debugPrint('DEBUG: Contact Info: "$cleanContact" (len: \\${cleanContact.length})');

          if (widget.mode == RecoveryMode.forgotPassword) {
            // Require both Customer ID and contact
            if (cleanId == 'HDFC123' && (cleanContact == 'upamanyusuksham@gmail.com' || cleanContact == '9876543210')) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RecoveryOtpScreen(
                    customerId: cleanId,
                    destination: cleanContact,
                  ),
                ),
              );
            } else {
              setState(() { _isLoading = false; });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invalid details. Please check your Customer ID and contact info.'),
                  backgroundColor: AppTheme.primaryRed,
                ),
              );
            }
          } else {
            // getCustomerId mode: only contact info required
            if (cleanContact == 'upamanyusuksham@gmail.com' || cleanContact == '9876543210') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RecoveryOtpScreen(
                    customerId: '', // Not known yet
                    destination: cleanContact,
                  ),
                ),
              );
            } else {
              setState(() { _isLoading = false; });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invalid details. Please check your contact info.'),
                  backgroundColor: AppTheme.primaryRed,
                ),
              );
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('Account Recovery'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isSmallMobile = constraints.maxWidth < 400;
          final bool isUltraSmall = constraints.maxWidth < 365;

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                isUltraSmall ? 16.0 : (isSmallMobile ? 20.0 : AppTheme.spacing24),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isUltraSmall ? 16.0 : (isSmallMobile ? 24.0 : AppTheme.spacing32),
                    vertical: isSmallMobile ? 24.0 : AppTheme.spacing32,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge * 2),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: SvgPicture.asset(
                            'assets/images/hdfc-bank-logo.svg',
                            width: isUltraSmall ? 120 : 160,
                            height: isUltraSmall ? 32 : 44,
                          ),
                        ),
                        SizedBox(height: isUltraSmall ? 16 : AppTheme.spacing24),

                        Center(
                          child: Text(
                            widget.mode == RecoveryMode.forgotPassword
                                ? 'Identify Yourself'
                                : 'Get Customer ID',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isUltraSmall ? 20 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            widget.mode == RecoveryMode.forgotPassword
                                ? 'Enter your details to receive an OTP'
                                : 'Enter your registered Email or Phone to receive an OTP',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isUltraSmall ? 12 : 14,
                            ),
                          ),
                        ),
                        SizedBox(height: isUltraSmall ? 24 : AppTheme.spacing32),

                        if (widget.mode == RecoveryMode.forgotPassword) ...[
                          // Customer ID
                          const Text(
                            'Customer ID',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _customerIdController,
                            validator: (value) =>
                                (value == null || value.isEmpty) ? 'Please enter Customer ID' : null,
                            decoration: InputDecoration(
                              hintText: 'e.g. HDFC123',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                              errorStyle: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing24),
                        ],

                        // Email or Phone (always shown)
                        const Text(
                          'Registered Email or Phone',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _contactController,
                          validator: (value) =>
                              (value == null || value.isEmpty) ? 'Please enter Email or Phone' : null,
                          decoration: InputDecoration(
                            hintText: 'e.g. test@hdfc.com',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            errorStyle: const TextStyle(color: Colors.white),
                          ),
                        ),
                        
                        SizedBox(height: isUltraSmall ? 24 : AppTheme.spacing32),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleVerify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryRed,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Send OTP',
                                    style: TextStyle(
                                      fontSize: isUltraSmall ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
