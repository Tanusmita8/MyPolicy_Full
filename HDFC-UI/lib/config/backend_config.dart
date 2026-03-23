import 'package:flutter/foundation.dart';

/// Direct microservice URLs (no BFF). Override with `--dart-define` when needed.
class BackendConfig {
  BackendConfig._();

  static const String customerServiceBase = String.fromEnvironment(
    'CUSTOMER_SERVICE_URL',
    defaultValue: 'http://localhost:8081',
  );
  static const String policyServiceBase = String.fromEnvironment(
    'POLICY_SERVICE_URL',
    defaultValue: 'http://localhost:8085',
  );
  static const String dataPipelineBase = String.fromEnvironment(
    'DATA_PIPELINE_URL',
    defaultValue: 'http://localhost:8082',
  );

  static void debugLogEndpoints() {
    if (kDebugMode) {
      // ignore: avoid_print
      print(
        '[Backend] customer=$customerServiceBase policy=$policyServiceBase pipeline=$dataPipelineBase',
      );
    }
  }
}
