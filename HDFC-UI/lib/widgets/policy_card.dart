import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/policy_model.dart';
import '../theme/app_theme.dart';
import '../screens/policy_detail_screen.dart';

class PolicyCard extends StatelessWidget {
  final Policy policy;
  final String customerId;
  final String customerName;

  const PolicyCard({
    super.key,
    required this.policy,
    required this.customerId,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PolicyDetailScreen(
              policy: policy,
              customerId: customerId,
              customerName: customerName,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing12),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.softShadow,
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                ),

                const SizedBox(width: AppTheme.spacing16),

            
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 70),
                        child: Text(
                          policy.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 13, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      /// POLICY ID
                      Text(
                        policy.policyId,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        policy.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10, 
                          color: AppTheme.textGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                     
                      Text(
                        'Expires: ${DateFormat('dd/MM/yyyy').format(policy.expiryDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Annual Premium',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    color: AppTheme.textGrey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _formatCurrency(policy.annualPremium),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 13, 
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacing16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sum Insured',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    color: AppTheme.textGrey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _formatCurrency(policy.sumInsured),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 13, 
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                const Padding(
                  padding: EdgeInsets.only(top: 80), 
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),

      
            Positioned(
              top: 0,
              right: 0,
              child: _StatusBadge(status: policy.status),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}

class _StatusBadge extends StatelessWidget {
  final PolicyStatus status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == PolicyStatus.active;
    final isDue = status == PolicyStatus.due;
    final isExpiringSoon = status == PolicyStatus.expiringsoon;

   final color = isActive
    ? AppTheme.statusActive
    : (isExpiringSoon
        ? AppTheme.statusexpiringsoon 
        : (isDue ? AppTheme.statusDue : AppTheme.statusExpired));

final label = isActive
    ? 'Active'
    : (isExpiringSoon
        ? 'Expiring Soon'
        : (isDue ? 'Due' : 'Expired'));

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
