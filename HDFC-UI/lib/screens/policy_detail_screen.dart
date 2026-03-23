import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/policy_model.dart';
import '../services/backend_api.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_appbar.dart';

class PolicyDetailScreen extends StatefulWidget {
  final Policy policy;
  final String customerId;
  final String customerName;

  const PolicyDetailScreen({
    super.key,
    required this.policy,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<PolicyDetailScreen> createState() => _PolicyDetailScreenState();
}

class _PolicyDetailScreenState extends State<PolicyDetailScreen> {
  Map<String, dynamic>? _apiDetail;
  bool _loadingDetail = false;
  String? _detailError;

  @override
  void initState() {
    super.initState();
    final cid = int.tryParse(widget.customerId.trim());
    final rid = widget.policy.portfolioRecordId;
    if (cid != null && rid != null && rid.isNotEmpty) {
      _fetchDetail(cid, rid);
    }
  }

  Future<void> _fetchDetail(int customerId, String recordId) async {
    setState(() {
      _loadingDetail = true;
      _detailError = null;
    });
    final json = await BackendApi.getPolicyDetail(customerId.toString(), recordId);
    if (!mounted) return;
    setState(() {
      _loadingDetail = false;
      if (json == null) {
        _detailError = 'Could not load policy detail from server.';
      } else {
        _apiDetail = json;
      }
    });
  }

  String _statusDisplay() {
    final s = _apiDetail?['statusLabel']?.toString();
    if (s != null && s.isNotEmpty) {
      return s.replaceAll('_', ' ');
    }
    return widget.policy.status.name.toUpperCase();
  }

  String _coverageLabel() {
    final p = _apiDetail?['planLabel'] ?? _apiDetail?['sourceCollection'];
    if (p != null && p.toString().isNotEmpty) {
      return p.toString();
    }
    return widget.policy.category.displayName;
  }

  String _startDate() {
    final s = _apiDetail?['startDate'];
    if (s is String && s.isNotEmpty) {
      final d = DateTime.tryParse(s);
      if (d != null) return DateFormat('dd/MM/yyyy').format(d);
    }
    return '—';
  }

  String _expiryDate() {
    final s = _apiDetail?['endDate'];
    if (s is String && s.isNotEmpty) {
      final d = DateTime.tryParse(s);
      if (d != null) return DateFormat('dd/MM/yyyy').format(d);
    }
    return DateFormat('dd/MM/yyyy').format(widget.policy.expiryDate);
  }

  String _premiumLine() {
    final p = _apiDetail?['premiumAmount'];
    if (p is num) {
      return '₹ ${NumberFormat('#,##,###').format(p.toDouble())}/year';
    }
    return '₹ ${NumberFormat('#,##,###').format(widget.policy.annualPremium)}/year';
  }

  String _sumAssuredLine() {
    final p = _apiDetail?['sumAssured'];
    if (p is num) {
      return '₹ ${NumberFormat('#,##,###').format(p.toDouble())}';
    }
    return '₹ ${NumberFormat('#,##,###').format(widget.policy.sumInsured)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: CustomAppBar(
        customerName: widget.customerName,
        customerId: widget.customerId,
        onLogoTap: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loadingDetail)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(),
                ),
              if (_detailError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _detailError!,
                    style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
                  ),
                ),
              _buildSummaryHeader(context),
              const SizedBox(height: AppTheme.spacing24),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildPolicyOverview(context)),
                        const SizedBox(width: AppTheme.spacing24),
                        Expanded(child: _buildCoverageDetails(context)),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildPolicyOverview(context),
                        const SizedBox(height: AppTheme.spacing24),
                        _buildCoverageDetails(context),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: AppTheme.spacing32),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 650;

        final content = [
          Container(
            padding: EdgeInsets.all(isCompact ? AppTheme.spacing12 : AppTheme.spacing16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Icon(
              Icons.favorite_outline,
              size: isCompact ? 36 : 48,
              color: Colors.black,
            ),
          ),
          SizedBox(
            width: isCompact ? 0 : AppTheme.spacing24,
            height: isCompact ? AppTheme.spacing16 : 0,
          ),
          isCompact
              ? Column(
                  children: [
                    Text(
                      'Policy Details : ${widget.policy.name}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Policy Number : ${widget.policy.policyId}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: AppTheme.textGrey,
                          ),
                    ),
                  ],
                )
              : Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Policy Details : ${widget.policy.name}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Policy Number : ${widget.policy.policyId}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              color: AppTheme.textGrey,
                            ),
                      ),
                    ],
                  ),
                ),
          SizedBox(
            width: isCompact ? 0 : AppTheme.spacing24,
            height: isCompact ? AppTheme.spacing16 : 0,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            ),
            child: Text(
              'Expiry Date : ${_expiryDate()}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacing24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: AppTheme.textGrey.withValues(alpha: 0.2)),
            boxShadow: AppTheme.softShadow,
          ),
          child: isCompact
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: content,
                )
              : Row(children: content),
        );
      },
    );
  }

  Widget _buildPolicyOverview(BuildContext context) {
    final mm = _apiDetail?['matchMethod']?.toString();
    return _buildDetailSection(
      context,
      title: 'Policy Overview',
      items: [
        _DetailItem('Status', _statusDisplay()),
        _DetailItem('Coverage', _coverageLabel()),
        _DetailItem('Start Date', _startDate()),
        _DetailItem('Expiry Date', _expiryDate()),
        _DetailItem('Premium', _premiumLine()),
        _DetailItem(
          'Policy Term',
          mm != null && mm.isNotEmpty ? 'See source policy ($mm)' : '—',
        ),
        const _DetailItem('Payment Term', '—'),
        _DetailItem('Insurer', _apiDetail?['insurer']?.toString() ?? '—'),
      ],
    );
  }

  Widget _buildCoverageDetails(BuildContext context) {
    return _buildDetailSection(
      context,
      title: 'Coverage Details',
      items: [
        _DetailItem('Sum Assured', _sumAssuredLine()),
        const _DetailItem('Nominee', '—'),
        const _DetailItem('Grace Period', '—'),
        const _DetailItem('Death Benefit', '—'),
        const _DetailItem('Critical Illness', '—'),
        const _DetailItem('Maturity Benefit', '—'),
        const _DetailItem('Payout options', '—'),
      ],
    );
  }

  Widget _buildDetailSection(
      BuildContext context, {required String title, required List<_DetailItem> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacing16),
            color: AppTheme.primaryBlue,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ...items.map((item) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing20, vertical: AppTheme.spacing12),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: AppTheme.textGrey.withValues(alpha: 0.1))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        item.label,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                    const Text(' : '),
                    Expanded(
                      flex: 1,
                      child: Text(
                        item.value,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;

        final buttons = [
          _ActionButton(
            icon: Icons.file_download_outlined,
            label: 'Download Policy',
            onTap: () {},
          ),
          SizedBox(
            width: isCompact ? 0 : AppTheme.spacing16,
            height: isCompact ? AppTheme.spacing16 : 0,
          ),
          _ActionButton(
            icon: Icons.description_outlined,
            label: 'File a Claim',
            onTap: () {},
          ),
          SizedBox(
            width: isCompact ? 0 : AppTheme.spacing16,
            height: isCompact ? AppTheme.spacing16 : 0,
          ),
          _ActionButton(
            icon: Icons.shield_outlined,
            label: 'Manage Policy',
            onTap: () {},
          ),
        ];

        return isCompact
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: buttons,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: buttons
                    .map((widget) => widget is _ActionButton
                        ? Expanded(child: widget)
                        : widget)
                    .toList(),
              );
      },
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  const _DetailItem(this.label, this.value);
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: Colors.black),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
