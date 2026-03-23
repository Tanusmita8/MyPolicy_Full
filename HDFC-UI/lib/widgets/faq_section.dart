import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FaqSection extends StatelessWidget {
  final VoidCallback? onViewAllPressed;

  const FaqSection({
    super.key,
    this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.textDark,
                ),
          ),
          const SizedBox(height: 16),
          _buildFaqItem(
            'How do I file a claim?',
            'To file a claim, navigate to the Claims section and click on "File a Claim". Select the policy and submit the required documents.',
          ),
          const Divider(height: 1, color: AppTheme.borderBlue),
          _buildFaqItem(
            'How can I download my policy document?',
            'Open the policy from your dashboard and go to Documents & Certificates. From there you can download your policy PDF.',
          ),
          const Divider(height: 1, color: AppTheme.borderBlue),
          _buildFaqItem(
            'What should I do if my payment fails?',
            'If your payment fails, retry the payment from the Track Payments section or contact support through the chat option.',
          ),
          const Divider(height: 1, color: AppTheme.borderBlue),
          _buildFaqItem(
            'How do I track my claim status?',
            'Go to Claims → Track Claim Status and enter your claim reference number to view updates.',
          ),
          const Divider(height: 1, color: AppTheme.borderBlue),
          _buildFaqItem(
            'How do I update nominee details?',
            'Navigate to Policy Service Requests and select Update Nominee to submit the updated information.',
          ),
          const Divider(height: 1, color: AppTheme.borderBlue),
          _buildFaqItem(
            'How can I contact support?',
            'You can contact support through Chat With Us or raise a support ticket in the Get Help section.',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewAllPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'View All FAQs',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF1F2937),
          ),
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 16),
        iconColor: AppTheme.primaryBlue,
        collapsedIconColor: AppTheme.textGrey,
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
