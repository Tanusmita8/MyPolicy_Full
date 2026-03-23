import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../auth/auth_session.dart';
import '../theme/app_theme.dart';
import '../screens/login_screen.dart';
import '../screens/analytical_dashboard.dart';
import '../screens/profile_screen.dart';
import '../screens/help_screen.dart';
import '../screens/insights_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String customerName;
  final String customerId;
  final VoidCallback? onLogoTap;
  final bool showBackButton;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    required this.customerName,
    required this.customerId,
    this.onLogoTap,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Material(
      color: AppTheme.primaryBlue,
      child: Container(
        height: preferredSize.height,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? AppTheme.spacing16 : AppTheme.spacing24,
          vertical: 6,
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                ),
              // HDFC Logo on app bar
              InkWell(
                onTap: onLogoTap,
                child: SvgPicture.asset(
                  'assets/images/hdfc-bank-logo.svg',
                  height: isMobile
                      ? (screenWidth < 360 ? 18 : 22)
                      : 29,
                ),
              ),

              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Customer Name + ID on app bar
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            customerName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: isMobile ? 12 : 14,
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          if (!isMobile) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Customer ID: $customerId',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: AppTheme.spacing8),

                
                    MenuAnchor(
                      style: MenuStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.white),
                        elevation: WidgetStateProperty.all(10),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium),
                          ),
                        ),
                        padding: WidgetStateProperty.all(
                            const EdgeInsets.all(AppTheme.spacing8)),
                        shadowColor: WidgetStateProperty.all(
                            Colors.black.withValues(alpha: 0.2)),
                      ),
                      builder: (context, controller, child) {
                        return InkWell(
                          onTap: () {
                            controller.isOpen
                                ? controller.close()
                                : controller.open();
                          },
                          borderRadius: BorderRadius.circular(22),
                          child: CircleAvatar(
                            radius: isMobile ? 12 : 18,
                            backgroundColor: Colors.white,
                            child: Text(
                              _getInitials(customerName),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 10 : 14,
                                  ),
                            ),
                          ),
                        );
                      },
                      menuChildren: [
                        _buildMenuItem(
                          context,
                          icon: Icons.person_outline,
                          title: 'Profile',
                        ),
                        const SizedBox(height: 8),
                        _buildMenuItem(
                          context,
                          icon: Icons.grid_view_outlined,
                          title: 'Coverage analytics',
                          subtitle: 'advisory & charts',
                        ),
                        const SizedBox(height: 8),
                        _buildMenuItem(
                          context,
                          icon: Icons.insights_outlined,
                          title: 'Insurance insights',
                          subtitle: 'gaps vs recommended cover',
                        ),
                        const SizedBox(height: 8),
                        _buildMenuItem(
                          context,
                          icon: Icons.help_outline,
                          title: 'Get Help',
                        ),
                        const SizedBox(height: 8),
                        _buildMenuItem(
                          context,
                          icon: Icons.logout,
                          title: 'Logout',
                        ),
                      ],
                    ),

                    SizedBox(width: isMobile ? 4 : AppTheme.spacing8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return MenuItemButton(
      onPressed: () {
        if (title == 'Coverage analytics') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalyticsDashboard(
                customerName: customerName,
                customerId: customerId,
              ),
            ),
          );
        } else if (title == 'Insurance insights') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsightsScreen(
                customerName: customerName,
                customerId: customerId,
              ),
            ),
          );
        } else if (title == 'Profile') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                customerName: customerName,
                customerId: customerId,
              ),
            ),
          );
        } else if (title == 'Get Help') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HelpScreen(
                customerName: customerName,
                customerId: customerId,
              ),
            ),
          );
        } else if (title == 'Logout') {
          AuthSession.clear();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        } else {
          debugPrint('Menu clicked: $title');
        }
      },
      style: MenuItemButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Container(
        width: 180,
        height: 64,
        padding:
            const EdgeInsets.symmetric(horizontal: AppTheme.spacing12),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2F9),
          borderRadius:
              BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);

  String _getInitials(String name) {
    final parts =
        name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }
}
