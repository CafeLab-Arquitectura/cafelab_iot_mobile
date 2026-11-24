class TelemetryRecord {
  final int? id;
  final int coffeeLotId;
  final double temperature;
  final double humidity;
  final DateTime timestamp;

  TelemetryRecord({
    this.id,
    required this.coffeeLotId,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  factory TelemetryRecord.fromJson(Map<String, dynamic> json) {
    int? toNullableInt(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toInt();
      return int.tryParse('$val');
    }

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

    return TelemetryRecord(
      id: toNullableInt(json['id']),
      coffeeLotId: toInt(json['coffeeLotId']),
      temperature: toDouble(json['temperature']),
      humidity: toDouble(json['humidity']),
      timestamp: parseDate(json['timestamp']),
    );
  }
}