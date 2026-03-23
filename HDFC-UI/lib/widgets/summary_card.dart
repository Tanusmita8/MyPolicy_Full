import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable summary card widget for dashboard metrics
class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing12, // Reduced from 16
          vertical: AppTheme.spacing4, // Reduced from 8
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.borderBlue,
            width: 1.5,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing8), // Reduced from 12
              child: Icon(
                icon,
                color: AppTheme.primaryBlue,
                size: 22, // Reduced from 28
              ),
            ),
            const SizedBox(width: AppTheme.spacing12), // Reduced from 16
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textGrey,
                          fontSize: 10, // Reduced from 11
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacing2), // Reduced from 4
                  Text(
                    value,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 16, // Reduced from 18
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppTheme.spacing2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 9,
                            color: AppTheme.textGrey,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else ...[
                    const SizedBox(height: AppTheme.spacing2),
                    Text(
                      '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 9,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
    );
  }
}
