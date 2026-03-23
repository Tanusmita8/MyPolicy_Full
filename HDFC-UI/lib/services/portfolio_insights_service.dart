import 'dart:math' as math;

/// Derives coverage gaps from data-pipeline portfolio rows, aligned with
/// pipeline advisory rules (life: premium × multiplier, health/auto floors).
class PortfolioInsightsSnapshot {
  final double lifeCoveragePercent;
  final double lifePresentCover;
  final double lifeRecommendedCover;
  final double lifeGap;

  final double healthCoveragePercent;
  final double healthPresentCover;
  final double healthRecommendedCover;
  final double healthGap;

  final double vehicleCoveragePercent;
  final double vehiclePresentCover;
  final double vehicleRecommendedCover;
  final double vehicleGap;

  final double totalGap;
  /// HIGH | MEDIUM | LOW — from advisory severities + gap size.
  final String riskStatus;
  final int? backendGapsIdentified;
  final bool portfolioLoaded;

  const PortfolioInsightsSnapshot({
    required this.lifeCoveragePercent,
    required this.lifePresentCover,
    required this.lifeRecommendedCover,
    required this.lifeGap,
    required this.healthCoveragePercent,
    required this.healthPresentCover,
    required this.healthRecommendedCover,
    required this.healthGap,
    required this.vehicleCoveragePercent,
    required this.vehiclePresentCover,
    required this.vehicleRecommendedCover,
    required this.vehicleGap,
    required this.totalGap,
    required this.riskStatus,
    this.backendGapsIdentified,
    this.portfolioLoaded = true,
  });

  static PortfolioInsightsSnapshot empty() {
    return const PortfolioInsightsSnapshot(
      lifeCoveragePercent: 0,
      lifePresentCover: 0,
      lifeRecommendedCover: 0,
      lifeGap: 0,
      healthCoveragePercent: 0,
      healthPresentCover: 0,
      healthRecommendedCover: 0,
      healthGap: 0,
      vehicleCoveragePercent: 0,
      vehiclePresentCover: 0,
      vehicleRecommendedCover: 0,
      vehicleGap: 0,
      totalGap: 0,
      riskStatus: 'LOW',
      portfolioLoaded: false,
    );
  }

  /// Rating labels for the progress bar (percent of recommended cover met).
  static String ratingForPercent(double percent) {
    if (percent >= 90) return 'Excellent';
    if (percent >= 75) return 'Good';
    if (percent >= 60) return 'Moderate';
    if (percent >= 45) return 'Fair';
    if (percent >= 30) return 'Low';
    if (percent >= 15) return 'Very Low';
    return 'Critical';
  }
}

class PortfolioInsightsService {
  PortfolioInsightsService._();

  /// Defaults match `mypolicy.advisory` in data-pipeline `application.yaml`.
  static const int lifePremiumMultiplier = 10;
  static const double healthCoverageMin = 300000;
  static const double autoIdvMin = 100000;

  /// [mergedPortfolio] = result of [BackendApi.getMergedPortfolio] (needs `policies` list).
  /// [advisoryJson] = optional [BackendApi.getAdvisory] body for risk band + count.
  static PortfolioInsightsSnapshot compute({
    required Map<String, dynamic>? mergedPortfolio,
    Map<String, dynamic>? advisoryJson,
  }) {
    if (mergedPortfolio == null) {
      return PortfolioInsightsSnapshot.empty();
    }

    final raw = mergedPortfolio['policies'];
    if (raw is! List) {
      return PortfolioInsightsSnapshot.empty();
    }

    double lifeSum = 0, lifePrem = 0;
    double healthSum = 0;
    int healthN = 0;
    double vehicleSum = 0;
    int vehicleN = 0;

    for (final e in raw) {
      if (e is! Map<String, dynamic>) continue;
      final src = (e['policyType'] ?? e['planName'] ?? '').toString().toLowerCase();
      final prem = _toDouble(e['premiumAmount']);
      final sum = _toDouble(e['sumAssured']);

      if (src.contains('life')) {
        lifeSum += sum;
        lifePrem += prem;
      } else if (src.contains('health')) {
        healthSum += sum;
        healthN++;
      } else if (_isVehicleSource(src)) {
        vehicleSum += sum;
        vehicleN++;
      }
    }

    final lifeRec = lifePrem * lifePremiumMultiplier;
    final lifeGap = math.max(0.0, lifeRec - lifeSum);
    final double lifePct = lifeRec > 0
        ? (lifeSum / lifeRec * 100).clamp(0.0, 999.0).toDouble()
        : 0.0;

    final healthRec = healthN * healthCoverageMin;
    final healthGap = math.max(0.0, healthRec - healthSum);
    final double healthPct = healthRec > 0
        ? (healthSum / healthRec * 100).clamp(0.0, 999.0).toDouble()
        : 0.0;

    final vehicleRec = vehicleN * autoIdvMin;
    final vehicleGap = math.max(0.0, vehicleRec - vehicleSum);
    final double vehiclePct = vehicleRec > 0
        ? (vehicleSum / vehicleRec * 100).clamp(0.0, 999.0).toDouble()
        : 0.0;

    final totalGap = lifeGap + healthGap + vehicleGap;

    int? gapsIdentified;
    if (advisoryJson != null) {
      final s = advisoryJson['summary'];
      if (s is Map && s['gapsIdentified'] != null) {
        gapsIdentified = int.tryParse(s['gapsIdentified'].toString());
      }
    }

    final risk = _deriveRisk(
      totalGap: totalGap,
      gapsIdentified: gapsIdentified,
      advisoryJson: advisoryJson,
    );

    return PortfolioInsightsSnapshot(
      lifeCoveragePercent: lifePct,
      lifePresentCover: lifeSum,
      lifeRecommendedCover: lifeRec,
      lifeGap: lifeGap,
      healthCoveragePercent: healthPct,
      healthPresentCover: healthSum,
      healthRecommendedCover: healthRec,
      healthGap: healthGap,
      vehicleCoveragePercent: vehiclePct,
      vehiclePresentCover: vehicleSum,
      vehicleRecommendedCover: vehicleRec,
      vehicleGap: vehicleGap,
      totalGap: totalGap,
      riskStatus: risk,
      backendGapsIdentified: gapsIdentified,
      portfolioLoaded: true,
    );
  }

  static bool _isVehicleSource(String src) {
    if (src.contains('auto')) return true;
    if (src.contains('motor')) return true;
    if (src.contains('vehicle')) return true;
    return false;
  }

  static double _toDouble(Object? v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static String _deriveRisk({
    required double totalGap,
    required int? gapsIdentified,
    Map<String, dynamic>? advisoryJson,
  }) {
    int high = 0, medium = 0;
    final adv = advisoryJson?['advisory'];
    if (adv is List) {
      for (final n in adv) {
        if (n is Map) {
          final sev = n['severity']?.toString().toLowerCase();
          if (sev == 'high') high++;
          if (sev == 'medium') medium++;
        }
      }
    }

    if (high >= 2 || totalGap >= 1500000 || (gapsIdentified != null && gapsIdentified >= 12)) {
      return 'HIGH';
    }
    if (high >= 1 || medium >= 3 || totalGap >= 400000 || (gapsIdentified != null && gapsIdentified >= 5)) {
      return 'MEDIUM';
    }
    return 'LOW';
  }
}
