import 'package:flutter/material.dart';

import '../models/policy_model.dart';
import '../services/backend_api.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_appbar.dart';
import 'policy_detail_screen.dart';

class DocumentsScreen extends StatefulWidget {
  final String customerName;
  final String customerId;

  const DocumentsScreen({
    super.key,
    required this.customerName,
    required this.customerId,
  });

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<Policy> _policies = [];
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
    if (!mounted) return;
    final policies = <Policy>[];
    if (merged != null) {
      final list = merged['policies'] as List<dynamic>?;
      if (list != null) {
        for (final e in list) {
          if (e is Map<String, dynamic>) {
            policies.add(Policy.fromBffPolicy(e));
          }
        }
      }
    }
    setState(() {
      _loading = false;
      _policies = policies;
      if (merged == null) {
        _error =
            'Could not load policies. Ensure customer-service and data-pipeline are running.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: CustomAppBar(
        customerName: widget.customerName,
        customerId: widget.customerId,
        onLogoTap: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(AppTheme.spacing24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Documents & Certificates',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  color: AppTheme.textDark,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      Text(
                        'Open policy details from your unified_portfolio records.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textGrey,
                              fontSize: 16,
                            ),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
                          ),
                        ),
                      const SizedBox(height: AppTheme.spacing32),
                      if (_policies.isEmpty)
                        const Text('No policies to list for this customer.')
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _policies.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: AppTheme.spacing16),
                          itemBuilder: (context, index) {
                            final policy = _policies[index];
                            return _DocumentCard(
                              policy: policy,
                              customerName: widget.customerName,
                              customerId: widget.customerId,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final Policy policy;
  final String customerName;
  final String customerId;

  const _DocumentCard({
    required this.policy,
    required this.customerName,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.borderBlue),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppTheme.primaryBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  policy.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Policy ID: ${policy.policyId}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textGrey,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Category: ${policy.category.displayName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textGrey,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PolicyDetailScreen(
                    policy: policy,
                    customerName: customerName,
                    customerId: customerId,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new, size: 20),
            label: const Text('View detail'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing20,
                vertical: AppTheme.spacing12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
