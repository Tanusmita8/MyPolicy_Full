import 'package:flutter/material.dart';

import '../config/backend_config.dart';
import '../services/backend_api.dart';
import '../services/portfolio_insights_service.dart';
import '../widgets/custom_appbar.dart';

/// Insurance insights driven by data-pipeline `GET /api/portfolio` + optional `GET /api/advisory`.
class InsightsScreen extends StatefulWidget {
  final String customerName;
  final String customerId;

  const InsightsScreen({
    super.key,
    required this.customerName,
    required this.customerId,
  });

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  PortfolioInsightsSnapshot _snap = PortfolioInsightsSnapshot.empty();
  String? _error;
  bool _loading = true;

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
    final advisory = await BackendApi.getAdvisory(widget.customerId);
    if (!mounted) return;
    if (merged == null) {
      setState(() {
        _loading = false;
        _error =
            'Could not load portfolio. Is data-pipeline running at ${BackendConfig.dataPipelineBase}?';
        _snap = PortfolioInsightsSnapshot.empty();
      });
      return;
    }
    setState(() {
      _snap = PortfolioInsightsService.compute(
        mergedPortfolio: merged,
        advisoryJson: advisory,
      );
      _loading = false;
      if (!_snap.portfolioLoaded) {
        _error = 'No policy data in response.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF3),
      appBar: CustomAppBar(
        customerName: widget.customerName,
        customerId: widget.customerId,
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
        onLogoTap: () => Navigator.of(context).pop(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.orange.shade900),
                        ),
                      ),
                    const Text(
                      'Insurance Insights',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_snap.backendGapsIdentified != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Advisory notes (backend): ${_snap.backendGapsIdentified}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _buildOverallRiskCard(),
                    const SizedBox(height: 24),
                    const Text(
                      'Detailed breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInsightSection(
                      title: 'Life Insurance',
                      icon: Icons.favorite,
                      percent: _snap.lifeCoveragePercent,
                      current: _snap.lifePresentCover,
                      recommended: _snap.lifeRecommendedCover,
                      gap: _snap.lifeGap,
                      color: Colors.redAccent,
                    ),
                    _buildInsightSection(
                      title: 'Health Insurance',
                      icon: Icons.medical_services,
                      percent: _snap.healthCoveragePercent,
                      current: _snap.healthPresentCover,
                      recommended: _snap.healthRecommendedCover,
                      gap: _snap.healthGap,
                      color: Colors.green,
                    ),
                    _buildInsightSection(
                      title: 'Vehicle Insurance',
                      icon: Icons.directions_car,
                      percent: _snap.vehicleCoveragePercent,
                      current: _snap.vehiclePresentCover,
                      recommended: _snap.vehicleRecommendedCover,
                      gap: _snap.vehicleGap,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverallRiskCard() {
    final riskStatus = _snap.riskStatus;
    final riskColor = riskStatus == 'HIGH'
        ? Colors.red.shade700
        : (riskStatus == 'MEDIUM'
            ? Colors.orange.shade700
            : Colors.green.shade700);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall financial risk',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: riskColor, width: 1),
                ),
                child: Text(
                  riskStatus,
                  style: TextStyle(
                    color: riskColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹ ${_formatCurrency(_snap.totalGap)} total gap',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Shortfall vs recommended targets (sum assured vs premium×10 for life, '
            '₹3L per health policy, ₹1L per vehicle policy — same idea as pipeline advisory).',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightSection({
    required String title,
    required IconData icon,
    required double percent,
    required double current,
    required double recommended,
    required double gap,
    required Color color,
  }) {
    final rating = PortfolioInsightsSnapshot.ratingForPercent(percent);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (current > 0)
                Text(
                  rating,
                  style: TextStyle(
                    color: _getRatingColor(rating),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (current == 0 && recommended == 0)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'No policies of this type in unified_portfolio',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildValueColumn("Current cover", "₹ ${_formatCurrency(current)}"),
                _buildValueColumn("Recommended", "₹ ${_formatCurrency(recommended)}"),
                _buildValueColumn("Gap", "₹ ${_formatCurrency(gap)}",
                    isNegative: gap > 0),
              ],
            ),
          if (current > 0 || recommended > 0) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (percent / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_getRatingColor(rating)),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getAdvice(title, rating),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildValueColumn(String label, String value, {bool isNegative = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isNegative ? Colors.red.shade700 : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)} L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Color _getRatingColor(String rating) {
    switch (rating) {
      case "Excellent":
        return Colors.green.shade700;
      case "Good":
        return Colors.green.shade500;
      case "Moderate":
        return Colors.blue.shade600;
      case "Fair":
        return Colors.orange.shade400;
      case "Low":
        return Colors.orange.shade700;
      case "Very Low":
        return Colors.red.shade400;
      case "Critical":
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  String _getAdvice(String category, String rating) {
    if (rating == "Excellent" || rating == "Good") {
      return "You are well covered in this category. Maintain your current policies.";
    }
    if (rating == "Moderate" || rating == "Fair") {
      return "Consider increasing your coverage slightly to better protect your assets.";
    }
    return "Coverage is below the recommended target; review top-up or new policies.";
  }
}
