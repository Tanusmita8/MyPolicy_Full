import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpSection extends StatelessWidget {
  final String title;
  final List<Widget> cards;

  const HelpSection({
    super.key,
    required this.title,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            const Expanded(
              child: Divider(
                color: AppTheme.borderBlue,
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing16),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 3;
            if (constraints.maxWidth < 600) {
              crossAxisCount = 2;
            }
            if (constraints.maxWidth < 400) {
              crossAxisCount = 1;
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 140, // Increased to avoid overflow logic
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) => cards[index],
            );
          },
        ),
        const SizedBox(height: AppTheme.spacing32),
      ],
    );
  }
}
