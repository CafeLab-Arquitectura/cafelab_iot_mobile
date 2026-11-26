class ApiConfig {
  // Oracle Cloud Infrastructure (OCI) API Gateway
  static const String _defaultBackendUrl = 'https://spy-mins-communication-editions.trycloudflare.com';

  // Override at run time:
  // Android Emulator: --dart-define=API_BASE_URL=http://10.0.2.2:8080
  // iOS / macOS:      --dart-define=API_BASE_URL=http://localhost:8080
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBackendUrl,
  );

  static const String authBasePath = '/api/v1/authentication';
  static const String profilesBasePath = '/api/v1/profiles';
  static const String supplierBasePath = '/api/v1/suppliers';
  static const String coffeeLotsBasePath = '/api/v1/coffee-lots';
  static const String roastProfilesBasePath = '/api/v1/roast-profiles';
  static const String inventoryEntriesBasePath = '/api/v1/inventory-entries';
  static const String cuppingSessionsBasePath = '/api/v1/cupping-sessions';
  static const String recipesBasePath = '/api/v1/recipes';
  static const String portfoliosBasePath = '/api/v1/portfolios';
  static const String calibrationsBasePath = '/api/v1/calibrations';
  static const String defectsBasePath = '/api/v1/defects';
  static const String environmentThresholdsBasePath = '/api/v1/environment-thresholds';
  static const String monitoringBasePath = environmentThresholdsBasePath;
  static const String telemetryRecordsBasePath = '/api/v1/telemetry-records';
  static const String iotMonitoringBasePath = '/api/v1/iot-monitoring';
  static const String iotDashboardBasePath = '/api/v1/iot-monitoring/dashboard';
  static const String costingBatchesBasePath = '/api/v1/costing/batches';
  static const String costingPerformancesBasePath = '/api/v1/costing/lot-performances';
}
