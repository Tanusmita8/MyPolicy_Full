import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/backend_config.dart';

/// Login result (customer-service → `customer_details`).
class LoginResult {
  final bool success;
  final String? errorMessage;
  final String? token;
  final String? customerId;
  final String? displayName;

  const LoginResult._({
    required this.success,
    this.errorMessage,
    this.token,
    this.customerId,
    this.displayName,
  });

  factory LoginResult.ok({
    required String token,
    required String customerId,
    String? displayName,
  }) =>
      LoginResult._(
        success: true,
        token: token,
        customerId: customerId,
        displayName: displayName,
      );

  factory LoginResult.fail(String message) =>
      LoginResult._(success: false, errorMessage: message);
}

/// HTTP clients for customer-service, policy-service, and data-pipeline-service (no BFF).
class BackendApi {
  BackendApi._();

  static Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<Map<String, dynamic>?> _getJson(Uri uri) async {
    try {
      final res = await http.get(uri, headers: {'Accept': 'application/json'});
      if (res.statusCode != 200) {
        return null;
      }
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// `POST /api/v1/customers/login`
  static Future<LoginResult> login(
    String customerIdOrUserId,
    String password,
  ) async {
    final uri = Uri.parse(
      '${BackendConfig.customerServiceBase}/api/v1/customers/login',
    );
    try {
      final res = await http.post(
        uri,
        headers: _jsonHeaders,
        body: jsonEncode({
          'customerIdOrUserId': customerIdOrUserId,
          'password': password,
        }),
      );
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is! Map<String, dynamic>) {
          return LoginResult.fail('Unexpected login response');
        }
        final customer = decoded['customer'];
        String? id;
        String? name;
        if (customer is Map<String, dynamic>) {
          id = customer['customerId']?.toString();
          final fn = customer['firstName']?.toString().trim() ?? '';
          final ln = customer['lastName']?.toString().trim() ?? '';
          name = ('$fn $ln').trim();
          if (name.isEmpty) {
            name = fn;
          }
        }
        final token = decoded['token']?.toString();
        if (token == null || id == null || id.isEmpty) {
          return LoginResult.fail('Invalid login response from server');
        }
        return LoginResult.ok(
          token: token,
          customerId: id,
          displayName: name,
        );
      }
      String msg = 'Login failed (${res.statusCode})';
      try {
        final err = jsonDecode(res.body);
        if (err is Map && err['message'] != null) {
          msg = err['message'].toString();
        }
      } catch (_) {}
      return LoginResult.fail(msg);
    } catch (e) {
      return LoginResult.fail(
        'Cannot reach customer-service at ${BackendConfig.customerServiceBase}',
      );
    }
  }

  /// Merges `customer_details` (customer-service) + `unified_portfolio` (pipeline) like the old BFF portfolio.
  static Future<Map<String, dynamic>?> getMergedPortfolio(String customerId) async {
    final id = int.tryParse(customerId.trim());
    if (id == null) {
      return null;
    }
    final custUri = Uri.parse(
      '${BackendConfig.customerServiceBase}/api/v1/customers/details/$id',
    );
    final pipeUri = Uri.parse(
      '${BackendConfig.dataPipelineBase}/api/portfolio/$id',
    );

    final pipe = await _getJson(pipeUri);
    if (pipe == null) {
      return null;
    }

    final cust = await _getJson(custUri);

    final rawPolicies = pipe['policies'] as List<dynamic>?;
    final policies = <Map<String, dynamic>>[];
    if (rawPolicies != null) {
      for (final e in rawPolicies) {
        if (e is Map<String, dynamic>) {
          policies.add(_pipelineRowToDashboardShape(e));
        }
      }
    }

    return {
      'customer': cust,
      'policies': policies,
      'totalPolicies': pipe['totalPolicies'],
    };
  }

  static Map<String, dynamic> _pipelineRowToDashboardShape(Map<String, dynamic> p) {
    final end = p['policyEnd'];
    String? endDate;
    if (end is int) {
      final s = end.toString().padLeft(8, '0');
      if (s.length == 8) {
        endDate =
            '${s.substring(0, 4)}-${s.substring(4, 6)}-${s.substring(6, 8)}';
      }
    }
    final rid = p['recordId']?.toString();
    final pid = p['policyId']?.toString();
    return {
      'portfolioRecordId': rid,
      'id': rid ?? pid,
      'policyNumber': pid,
      'planName': p['sourceCollection'],
      'policyType': p['sourceCollection'],
      'premiumAmount': p['premium'],
      'sumAssured': p['sumAssured'],
      'insurerId': p['insurer'],
      'endDate': endDate,
    };
  }

  /// policy-service read model: customer_details + unified_portfolio counts.
  static Future<Map<String, dynamic>?> getCustomerProfile(String customerId) async {
    final id = int.tryParse(customerId.trim());
    if (id == null) {
      return null;
    }
    final uri = Uri.parse(
      '${BackendConfig.policyServiceBase}/api/v1/customers/$id/profile',
    );
    return _getJson(uri);
  }

  /// Single unified_portfolio document.
  static Future<Map<String, dynamic>?> getPolicyDetail(
    String customerId,
    String portfolioRecordId,
  ) async {
    final id = int.tryParse(customerId.trim());
    if (id == null) {
      return null;
    }
    final uri = Uri.parse(
      '${BackendConfig.policyServiceBase}/api/v1/customers/$id/policies/$portfolioRecordId',
    );
    return _getJson(uri);
  }

  /// Advisory / unified view (data-pipeline).
  static Future<Map<String, dynamic>?> getAdvisory(String customerId) async {
    final id = int.tryParse(customerId.trim());
    if (id == null) {
      return null;
    }
    final uri = Uri.parse('${BackendConfig.dataPipelineBase}/api/advisory/$id');
    return _getJson(uri);
  }
}
