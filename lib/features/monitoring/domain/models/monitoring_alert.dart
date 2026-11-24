class MonitoringAlert {
  final int id;
  final int coffeeLotId;
  final String metricType;
  final double currentValue;
  final double thresholdViolated;
  final bool isRead;
  final DateTime createdAt;

  MonitoringAlert({
    required this.id,
    required this.coffeeLotId,
    required this.metricType,
    required this.currentValue,
    required this.thresholdViolated,
    required this.isRead,
    required this.createdAt,
  });

  factory MonitoringAlert.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val is num) return val.toInt();
      return int.tryParse('$val') ?? 0;
    }

    double toDouble(dynamic val) {
      if (val is num) return val.toDouble();
      return double.tryParse('$val') ?? 0.0;
    }

    DateTime parseDate(dynamic val) {
      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return MonitoringAlert(
      id: toInt(json['id']),
      coffeeLotId: toInt(json['coffeeLotId']),
      metricType: (json['metricType'] as String?) ?? '',
      currentValue: toDouble(json['currentValue']),
      thresholdViolated: toDouble(json['thresholdViolated']),
      isRead: json['read'] ?? json['isRead'] ?? false,
      createdAt: parseDate(json['createdAt']),
    );
  }
}