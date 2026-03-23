import 'package:flutter/material.dart';
import '../models/policy_model.dart';
import '../theme/app_theme.dart';

/// Category filter widget with pill-shaped buttons
class CategoryFilter extends StatelessWidget {
  final double? maxWidth;
  final PolicyCategory selectedCategory;
  final Function(PolicyCategory) onCategorySelected;

  const CategoryFilter({
    super.key,
    this.maxWidth,
    required this.selectedCategory,
    required this.onCategorySelected,
  });
  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = PolicyCategory.values.map((category) {
      final isSelected = category == selectedCategory;
      final bool isSmall = maxWidth != null && maxWidth! < 650;
      
      return Padding(
        padding: const EdgeInsets.only(right: AppTheme.spacing12, bottom: AppTheme.spacing12),
        child: _FilterChip(
          label: category.displayName,
          isSelected: isSelected,
          onTap: () => onCategorySelected(category),
          isSmall: isSmall,
        ),
      );
    }).toList();

    if (maxWidth != null && maxWidth! < 650) {
      return Wrap(
        children: chips,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips,
      ),
    );
  }
}

//individual category filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSmall;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? AppTheme.spacing16 : AppTheme.spacing24,
          vertical: isSmall ? 4.0 : AppTheme.spacing12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.borderBlue,
            width: 1.5,
          ),
          boxShadow: isSelected ? AppTheme.cardShadow : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : AppTheme.textGrey,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12, 
          ),
        ),
      ),
    );
  }
}
