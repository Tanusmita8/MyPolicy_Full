import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/help_card.dart';
import '../widgets/help_section.dart';
import '../screens/documents_screen.dart';
import '../screens/faq_screen.dart';

class HelpScreen extends StatefulWidget {
  final String customerName;
  final String customerId;

  const HelpScreen({
    super.key,
    required this.customerName,
    required this.customerId,
  });

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const Color _blueIcon = Color(0xFF2563EB);
  static const Color _greenIcon = Color(0xFF16A34A);
  static const Color _orangeIcon = Color(0xFFF59E0B);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCardTap(String action) {
    if (action == 'Documents & Certificates') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentsScreen(
            customerName: widget.customerName,
            customerId: widget.customerId,
          ),
        ),
      );
      return;
    } else if (action == 'FAQs / Help Center') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FaqScreen(
            customerName: widget.customerName,
            customerId: widget.customerId,
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Action selected: $action'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Very light grey
      appBar: CustomAppBar(
        customerName: widget.customerName,
        customerId: widget.customerId,
        onLogoTap: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000), // Max width for web/desktop
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing24,
              vertical: AppTheme.spacing32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Title
                Text(
                  'Get Help',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: AppTheme.textDark,
                      ),
                ),
                const SizedBox(height: AppTheme.spacing24),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.cardShadow,
                    border: Border.all(color: AppTheme.borderBlue),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'How can we help you today?',
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textGrey,
                          ),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textGrey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing16,
                        vertical: AppTheme.spacing16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing32),

                // Self-Service Section
                HelpSection(
                  title: 'Self-Service',
                  cards: [
                    HelpCard(
                      icon: Icons.menu_book,
                      title: 'FAQs / Help Center',
                      iconColor: _blueIcon,
                      onTap: () => _onCardTap('FAQs / Help Center'),
                    ),
                    HelpCard(
                      icon: Icons.assignment,
                      title: 'Policy Service Requests',
                      iconColor: _blueIcon,
                      onTap: () => _onCardTap('Policy Service Requests'),
                    ),
                    HelpCard(
                      icon: Icons.description,
                      title: 'Documents & Certificates',
                      iconColor: _blueIcon,
                      onTap: () => _onCardTap('Documents & Certificates'),
                    ),
                  ],
                ),

                // Claims Section
                HelpSection(
                  title: 'Claims',
                  cards: [
                    HelpCard(
                      icon: Icons.fact_check,
                      title: 'File a Claim',
                      iconColor: _orangeIcon,
                      onTap: () => _onCardTap('File a Claim'),
                    ),
                    HelpCard(
                      icon: Icons.bar_chart,
                      title: 'Track Claim Status',
                      iconColor: _greenIcon,
                      onTap: () => _onCardTap('Track Claim Status'),
                    ),
                    HelpCard(
                      icon: Icons.medical_services,
                      title: 'Claim Assistance',
                      iconColor: _blueIcon,
                      onTap: () => _onCardTap('Claim Assistance'),
                    ),
                  ],
                ),

                // Payments Section
                HelpSection(
                  title: 'Payments',
                  cards: [
                    HelpCard(
                      icon: Icons.credit_card,
                      title: 'Track Payments',
                      iconColor: _greenIcon,
                      onTap: () => _onCardTap('Track Payments'),
                    ),
                    HelpCard(
                      icon: Icons.warning_amber_rounded,
                      title: 'Billing & Payment Issues',
                      iconColor: _orangeIcon,
                      onTap: () => _onCardTap('Billing & Payment Issues'),
                    ),
                  ],
                ),

                // Support Section
                HelpSection(
                  title: 'Support',
                  cards: [
                    HelpCard(
                      icon: Icons.chat,
                      title: 'Chat With Us',
                      iconColor: _blueIcon,
                      onTap: () => _onCardTap('Chat With Us'),
                    ),
                    HelpCard(
                      icon: Icons.confirmation_number,
                      title: 'Raise Support Ticket',
                      iconColor: _blueIcon,
                      onTap: () => _onCardTap('Raise Support Ticket'),
                    ),
                    HelpCard(
                      icon: Icons.star,
                      title: 'Advisor Feedback',
                      iconColor: _orangeIcon,
                      onTap: () => _onCardTap('Advisor Feedback'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
