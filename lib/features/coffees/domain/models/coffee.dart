class Coffee {
  const Coffee({
    required this.id,
    required this.name,
    required this.region,
    required this.variety,
    required this.totalWeight,
  });

  final int id;
  final String name;
  final String region;
  final String variety;
  final double totalWeight;

  factory Coffee.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val is num) return val.toInt();
      return int.tryParse('$val') ?? 0;
    }

    double toDouble(dynamic val) {
      if (val is num) return val.toDouble();
      return double.tryParse('$val') ?? 0.0;
    }

    return Coffee(
      id: toInt(json['id']),
      name: (json['name'] as String?) ?? '',
      region: (json['region'] as String?) ?? '',
      variety: (json['variety'] as String?) ?? '',
      totalWeight: toDouble(json['totalWeight']),
    );
  }
}
