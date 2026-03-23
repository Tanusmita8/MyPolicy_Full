import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/faq_section.dart';

class FaqScreen extends StatelessWidget {
  final String customerName;
  final String customerId;

  const FaqScreen({
    super.key,
    required this.customerName,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(
        customerName: customerName,
        customerId: customerId,
        onLogoTap: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(AppTheme.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Help Center',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: AppTheme.textDark,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FaqSection(
                  onViewAllPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('You are already viewing all major FAQs.')),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
