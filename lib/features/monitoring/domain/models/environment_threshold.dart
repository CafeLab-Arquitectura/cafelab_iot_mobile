class EnvironmentThreshold {
  final int? id;
  final int coffeeLotId;
  final double minTemperature;
  final double maxTemperature;
  final double minHumidity;
  final double maxHumidity;

  EnvironmentThreshold({
    this.id,
    required this.coffeeLotId,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minHumidity,
    required this.maxHumidity,
  });

  factory EnvironmentThreshold.fromJson(Map<String, dynamic> json) {
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

    return EnvironmentThreshold(
      id: toNullableInt(json['id']),
      coffeeLotId: toInt(json['coffeeLotId']),
      minTemperature: toDouble(json['minTemperature']),
      maxTemperature: toDouble(json['maxTemperature']),
      minHumidity: toDouble(json['minHumidity']),
      maxHumidity: toDouble(json['maxHumidity']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coffeeLotId': coffeeLotId,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'minHumidity': minHumidity,
      'maxHumidity': maxHumidity,
    };
  }
}