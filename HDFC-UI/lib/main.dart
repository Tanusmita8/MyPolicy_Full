import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/analytical_dashboard.dart';
import 'screens/recovery_verification_screen.dart';
import 'screens/recovery_otp_screen.dart';
import 'screens/policy_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'models/policy_model.dart';

void main() {
  runApp(const HDFCInsuranceApp());
}

/// Main application widget
class HDFCInsuranceApp extends StatelessWidget {
  const HDFCInsuranceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HDFC Insurance Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          
          case '/dashboard':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => DashboardScreen(
                customerId: args['customerId'],
                initialDisplayName: args['initialDisplayName'] as String?,
              ),
            );

          case '/analytics':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AnalyticsDashboard(
                customerName: args['customerName'],
                customerId: args['customerId'],
              ),
            );

          case '/recovery':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => RecoveryVerificationScreen(
                mode: args?['mode'] ?? RecoveryMode.forgotPassword,
              ),
            );

          case '/otp':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => RecoveryOtpScreen(
                customerId: args['customerId'],
                destination: args['destination'],
              ),
            );

          case '/policy-detail':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => PolicyDetailScreen(
                policy: args['policy'] as Policy,
                customerId: args['customerId'],
                customerName: args['customerName'],
              ),
            );

          case '/profile':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ProfileScreen(
                customerName: args['customerName'],
                customerId: args['customerId'],
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('No route defined for ${settings.name}')),
              ),
            );
        }
      },    );
  }
}