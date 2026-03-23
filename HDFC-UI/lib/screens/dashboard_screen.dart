import 'package:flutter/material.dart';
import '../models/policy_model.dart';
import '../services/backend_api.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/summary_card.dart';
import '../widgets/category_filter.dart';
import '../widgets/policy_card.dart';

class DashboardScreen extends StatefulWidget {
  final String customerId;
  /// Shown until portfolio loads (e.g. full name from login).
  final String? initialDisplayName;

  const DashboardScreen({
    super.key,
    required this.customerId,
    this.initialDisplayName,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PolicyCategory _selectedCategory = PolicyCategory.all;
  List<Policy> _allPolicies = [];
  bool _loadingPolicies = true;
  String? _portfolioError;
  String _customerDisplayName = 'Customer';

  @override
  void initState() {
    super.initState();
    final n = widget.initialDisplayName?.trim();
    if (n != null && n.isNotEmpty) {
      _customerDisplayName = n;
    }
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    final id = widget.customerId.trim();
    if (int.tryParse(id) == null) {
      setState(() {
        _portfolioError = 'Customer ID must be numeric (from customer_details).';
        _allPolicies = [];
        _loadingPolicies = false;
      });
      return;
    }

    final raw = await BackendApi.getMergedPortfolio(id);
    if (!mounted) return;
    if (raw == null) {
      setState(() {
        _portfolioError =
            'Could not load portfolio. Check customer-service (8081) and data-pipeline (8082).';
        _allPolicies = [];
        _loadingPolicies = false;
      });
      return;
    }

    final list = raw['policies'] as List<dynamic>?;
    final cust = raw['customer'] as Map<String, dynamic>?;
    var name = '';
    if (cust != null) {
      final fn = cust['firstName']?.toString().trim() ?? '';
      final ln = cust['lastName']?.toString().trim() ?? '';
      name = ('$fn $ln').trim();
    }
    if (name.isEmpty) {
      name = 'Customer';
    }

    final policies = <Policy>[];
    if (list != null && list.isNotEmpty) {
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          policies.add(Policy.fromBffPolicy(e));
        }
      }
    }

    setState(() {
      _customerDisplayName = name;
      _allPolicies = policies;
      if (policies.isEmpty) {
        _portfolioError = 'No policies in unified_portfolio for this customer.';
      }
      _loadingPolicies = false;
    });
  }

  List<Policy> get _allPoliciesView => _allPolicies;

  List<Policy> get _filteredPolicies {
    List<Policy> filtered;

    if (_selectedCategory == PolicyCategory.all) {
      filtered = List.from(_allPoliciesView);
    } else if (_selectedCategory == PolicyCategory.active) {
      filtered = _allPoliciesView
          .where((policy) => policy.status == PolicyStatus.active)
          .toList();
    } else if (_selectedCategory == PolicyCategory.due) {
      filtered = _allPoliciesView
          .where((policy) => policy.status == PolicyStatus.due)
          .toList();
    } else if (_selectedCategory == PolicyCategory.expired) {
      filtered = _allPoliciesView
          .where((policy) => policy.status == PolicyStatus.expired)
          .toList();
    } else if (_selectedCategory == PolicyCategory.expiringsoon) {
      filtered = _allPoliciesView
          .where((policy) => policy.status == PolicyStatus.expiringsoon)
          .toList();
    } else {
      filtered = _allPoliciesView
          .where((policy) => policy.category == _selectedCategory)
          .toList();
    }

    filtered.sort((a, b) {
      int getPriority(PolicyStatus status) {
        switch (status) {
          case PolicyStatus.due:
            return 0;
          case PolicyStatus.active:
            return 1;
          case PolicyStatus.expired:
            return 2;
          case PolicyStatus.expiringsoon:
            return 3;
        }
      }

      return getPriority(a.status).compareTo(getPriority(b.status));
    });

    return filtered;
  }

  double get _totalAnnualPremium =>
      _allPoliciesView.fold(0, (sum, p) => sum + p.annualPremium);

  double get _totalCoverage =>
      _allPoliciesView.fold(0, (sum, p) => sum + p.sumInsured);

  @override
  Widget build(BuildContext context) {
    final filteredPolicies = _filteredPolicies;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;

        return Scaffold(
          backgroundColor: AppTheme.backgroundGrey,

          appBar: CustomAppBar(
            customerName: _customerDisplayName,
            customerId: widget.customerId,
            onLogoTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(
                    customerId: widget.customerId,
                    initialDisplayName: widget.initialDisplayName,
                  ),
                ),
                (route) => false,
              );
            },
          ),

          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? AppTheme.spacing16 : AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isMobile ? AppTheme.spacing16 : AppTheme.spacing24),

                  /// Welcome Text
                  Text(
                    'Welcome back, $_customerDisplayName!',
                    style: isMobile
                        ? Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)
                        : Theme.of(context).textTheme.headlineLarge,
                  ),

                  SizedBox(height: isMobile ? AppTheme.spacing16 : AppTheme.spacing24),

                  /// SUMMARY CARDS
                  if (_portfolioError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
                      child: Text(
                        _portfolioError!,
                        style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                      ),
                    ),
                  _buildSummaryCards(constraints.maxWidth),

                  SizedBox(height: isMobile ? AppTheme.spacing16 : AppTheme.spacing24),

                  /// CATEGORY FILTER
                  if (!_loadingPolicies)
                  CategoryFilter(
                    maxWidth: constraints.maxWidth,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),

                  SizedBox(height: isMobile ? AppTheme.spacing16 : AppTheme.spacing24),

                  if (_loadingPolicies)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ))
                  else
                  _buildPolicyGrid(constraints.maxWidth, filteredPolicies),

                  SizedBox(height: isMobile ? AppTheme.spacing16 : AppTheme.spacing24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(double maxWidth) {
    final cards = [
      SummaryCard(
        icon: Icons.description_outlined,
        title: 'Total Policies',
        value: '${_allPoliciesView.length}',
      ),
      SummaryCard(
        icon: Icons.currency_rupee,
        title: 'Annual Premium',
        value: '₹ ${_formatAmount(_totalAnnualPremium)}',
        subtitle: 'Across all Policies',
      ),
      SummaryCard(
        icon: Icons.shield_outlined,
        title: 'Total Coverage',
        value: '₹ ${_formatAmount(_totalCoverage)}',
        subtitle: 'Sum assured amount',
      ),
    ];

    if (maxWidth < 650) {
      return Column(
        children: cards
            .map((card) => Padding(
                  padding: EdgeInsets.only(bottom: maxWidth < 650 ? AppTheme.spacing12 : AppTheme.spacing16),
                  child: card,
                ))
            .toList(),
      );
    } else {
     
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: cards.map((card) {
            return Expanded(
              child: card,
            );
          }).toList()
          .expand((widget) => [widget, const SizedBox(width: AppTheme.spacing16)])
          .toList()..removeLast(), // Interleave with spacing
        ),
      );
    }
  }

 
  Widget _buildPolicyGrid(double maxWidth, List<Policy> filteredPolicies) {
    int crossAxisCount;
    double childAspectRatio;

    if (maxWidth > 1400) {
      crossAxisCount = 4;
      childAspectRatio = 2.0;
    } 
    else if (maxWidth > 1100) {
      crossAxisCount = 3;
      childAspectRatio = 1.9;
    } 
    else if (maxWidth > 750) {
      crossAxisCount = 2;
      childAspectRatio = 2.0;
    } 
    else {
      crossAxisCount = 1;
      childAspectRatio = 2.1;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppTheme.spacing16,
        mainAxisSpacing: AppTheme.spacing16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: filteredPolicies.length,
      itemBuilder: (context, index) {
        return PolicyCard(
          policy: filteredPolicies[index],
          customerId: widget.customerId,
          customerName: _customerDisplayName,
        );
      },
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
