import 'package:flutter/material.dart';

import '../models/policy_model.dart';
import '../services/backend_api.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/donut_chart.dart';
import '../widgets/info_card.dart';
import 'dashboard_screen.dart';

/// Coverage analytics from data-pipeline `/api/advisory` + merged portfolio for donuts.
class AnalyticsDashboard extends StatefulWidget {
  final String customerName;
  final String customerId;

  const AnalyticsDashboard({
    super.key,
    required this.customerName,
    required this.customerId,
  });

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  List<Policy> _policies = [];
  Map<String, dynamic>? _advisory;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final merged = await BackendApi.getMergedPortfolio(widget.customerId);
    final adv = await BackendApi.getAdvisory(widget.customerId);
    if (!mounted) return;
    final policies = <Policy>[];
    final list = merged?['policies'] as List<dynamic>?;
    if (list != null) {
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          policies.add(Policy.fromBffPolicy(e));
        }
      }
    }
    setState(() {
      _loading = false;
      _policies = policies;
      _advisory = adv;
      if (merged == null && adv == null) {
        _error = 'Could not load analytics (pipeline / services unreachable).';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFE9EDF3),
        appBar: CustomAppBar(
          customerName: widget.customerName,
          customerId: widget.customerId,
          onLogoTap: () => _goHome(context),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final policies = _policies;
    final totalPolicies = policies.length;
    final totalProtection = policies
        .where((p) => p.status != PolicyStatus.expired)
        .fold(0.0, (sum, p) => sum + p.sumInsured);
    final expiringSoon = policies.where((p) => p.status == PolicyStatus.due).length;

    double getCategoryPercent(PolicyCategory category) {
      if (policies.isEmpty || totalPolicies == 0) return 0;
      final count = policies.where((p) => p.category == category).length;
      return (count / totalPolicies) * 100;
    }

    final lifePercent = getCategoryPercent(PolicyCategory.life);
    final healthPercent = getCategoryPercent(PolicyCategory.health);
    final vehiclePercent = totalPolicies == 0
        ? 0.0
        : policies
                .where((p) =>
                    p.category == PolicyCategory.others ||
                    p.name.toLowerCase().contains('motor') ||
                    p.name.toLowerCase().contains('auto'))
                .length /
            totalPolicies *
            100;

    final gaps = _advisory?['summary'];
    final gapCount = gaps is Map ? gaps['gapsIdentified'] : null;

    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF3),
      appBar: CustomAppBar(
        customerName: widget.customerName,
        customerId: widget.customerId,
        onLogoTap: () => _goHome(context),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isMobile = width < 600;
          double donutSpacing;
          if (width > 1300) {
            donutSpacing = 80;
          } else if (width > 900) {
            donutSpacing = 60;
          } else {
            donutSpacing = 30;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 40,
              vertical: isMobile ? 16 : 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: TextStyle(color: Colors.orange.shade900)),
                  ),
                const Text(
                  'Coverage analytics',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: isMobile ? 10 : 30,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
                    boxShadow: isMobile
                        ? []
                        : const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            )
                          ],
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: donutSpacing,
                    runSpacing: 40,
                    children: [
                      DonutChart(
                        title: 'Life Insurance',
                        percent: lifePercent.toInt(),
                        label: lifePercent > 50 ? 'Secure' : 'Low',
                      ),
                      DonutChart(
                        title: 'Health Insurance',
                        percent: healthPercent.toInt(),
                        label: healthPercent > 50 ? 'Covered' : 'Fair',
                      ),
                      DonutChart(
                        title: 'Vehicle / other',
                        percent: vehiclePercent.toInt(),
                        label: vehiclePercent > 20 ? 'Protected' : 'Verify',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    double cardWidth;
                    if (w > 1300) {
                      cardWidth = (w / 4) - 24;
                    } else if (w > 900) {
                      cardWidth = (w / 2) - 20;
                    } else {
                      cardWidth = w;
                    }
                    return Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: InfoCard(
                            icon: Icons.description_outlined,
                            color: const Color(0xFF2E49B8),
                            title: 'Policies linked',
                            value: '$totalPolicies',
                            subtitle: '$expiringSoon due within 30 days',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: InfoCard(
                            icon: Icons.shield_outlined,
                            color: const Color(0xFF2E49B8),
                            title: 'Total protection',
                            value: '₹ ${_formatAmount(totalProtection)}',
                            subtitle: 'non-expired sum assured',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: InfoCard(
                            icon: Icons.warning_amber_outlined,
                            color: const Color(0xFF2E49B8),
                            title: 'Advisory gaps',
                            value: gapCount != null ? '$gapCount' : '—',
                            subtitle: 'from /api/advisory',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: InfoCard(
                            icon: Icons.bar_chart,
                            color: const Color(0xFF2E49B8),
                            title: 'Risk status',
                            value: expiringSoon > 0 ? 'HIGH' : 'LOW',
                            subtitle: 'based on due policies',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          customerId: widget.customerId,
          initialDisplayName: widget.customerName,
        ),
      ),
      (route) => false,
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)} L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
