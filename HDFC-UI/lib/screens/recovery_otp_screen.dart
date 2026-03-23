import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class RecoveryOtpScreen extends StatefulWidget {
  final String customerId;
  final String destination;

  const RecoveryOtpScreen({
    super.key,
    required this.customerId,
    required this.destination,
  });

  @override
  State<RecoveryOtpScreen> createState() => _RecoveryOtpScreenState();
}

class _RecoveryOtpScreenState extends State<RecoveryOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  int _timerSeconds = 30;
  int _expirySeconds = 300; // 5 minutes expiry
  Timer? _cooldownTimer;
  Timer? _expiryTimer;
  bool _isLoading = false;
  int _attemptsLeft = 3;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    _startExpiryTimer();
  }

  void _startCooldown() {
    setState(() {
      _timerSeconds = 30;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startExpiryTimer() {
    _expiryTimer?.cancel();
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_expirySeconds > 0) {
        setState(() {
          _expirySeconds--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          _showFailureDialog('Your OTP has expired. Please start the recovery process again.');
        }
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _expiryTimer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleVerify() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    setState(() {
      _isLoading = true;
    });

    // Mock OTP verification (Correct code is 123456)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (otp == '123456') {
          _showSuccessDialog();
        } else {
          setState(() {
            _isLoading = false;
            _attemptsLeft--;
          });
          
          if (_attemptsLeft == 0) {
            _showFailureDialog('Too many attempts. Your account has been temporarily locked for security.');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invalid OTP. $_attemptsLeft attempts remaining.'),
                backgroundColor: AppTheme.primaryRed,
              ),
            );
          }
        }
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Your identity has been verified. A link to reset your password has been sent to your registered email.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Back from OTP
              Navigator.of(context).pop(); // Back from Verification to Login
            },
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  void _showFailureDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Access Denied'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isSmallMobile = constraints.maxWidth < 400;
          final bool isUltraSmall = constraints.maxWidth < 365; // Threshold for SE/S8
          
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isUltraSmall ? 6.0 : (isSmallMobile ? 12.0 : 24.0),
                vertical: 24.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isUltraSmall ? 10.0 : (isSmallMobile ? 18.0 : 32.0),
                    vertical: isSmallMobile ? 24.0 : 32.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge * 2),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.mark_email_read_outlined,
                        color: AppTheme.primaryBlue,
                        size: isUltraSmall ? 44 : 64,
                      ),
                      SizedBox(height: isUltraSmall ? 16 : AppTheme.spacing24),
                      Text(
                        'Enter Verification Code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: isUltraSmall ? 18 : (isSmallMobile ? 20 : 24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'ve sent a 6-digit code to\n${widget.destination}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: isUltraSmall ? 12 : 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'OTP expires in: ${_expirySeconds ~/ 60}:${(_expirySeconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: _expirySeconds < 60 ? AppTheme.primaryRed : AppTheme.textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isUltraSmall ? 16 : AppTheme.spacing24),
                      
                      // Fluid OTP Input Fields
                      Row(
                        children: List.generate(6, (index) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isUltraSmall ? 1.0 : 2.0,
                              ),
                              child: SizedBox(
                                height: isSmallMobile ? 48 : 56,
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  style: TextStyle(
                                    fontSize: isUltraSmall ? 16 : (isSmallMobile ? 18 : 24),
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: AppTheme.backgroundGrey,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 5) {
                                      _focusNodes[index + 1].requestFocus();
                                    } else if (value.isEmpty && index > 0) {
                                      _focusNodes[index - 1].requestFocus();
                                    }
                                    if (_controllers.every((c) => c.text.isNotEmpty)) {
                                      _handleVerify();
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      
                      SizedBox(height: isUltraSmall ? 24 : AppTheme.spacing32),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleVerify,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Verify OTP',
                                  style: TextStyle(
                                    fontSize: isUltraSmall ? 15 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      
                      SizedBox(height: isUltraSmall ? 16 : AppTheme.spacing24),
                      
                      _buildResendSection(isUltraSmall),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResendSection(bool isUltraSmall) {
    if (isUltraSmall) {
      return Column(
        children: [
          const Text(
            'Didn\'t receive the code?',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
          ),
          TextButton(
            onPressed: _timerSeconds == 0 ? _startCooldown : null,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _timerSeconds > 0 
                  ? 'Resend (${_timerSeconds}s)' 
                  : 'Resend OTP',
              style: TextStyle(
                color: _timerSeconds > 0 
                    ? AppTheme.textGrey 
                    : AppTheme.primaryRed,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Didn\'t receive the code? ',
          style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
        ),
        TextButton(
          onPressed: _timerSeconds == 0 ? _startCooldown : null,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _timerSeconds > 0 
                ? 'Resend (${_timerSeconds}s)' 
                : 'Resend OTP',
            style: TextStyle(
              color: _timerSeconds > 0 
                  ? AppTheme.textGrey 
                  : AppTheme.primaryRed,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
