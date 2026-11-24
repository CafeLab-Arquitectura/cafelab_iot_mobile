class CoffeeLotResponseDto {
  final int id;
  final int userId;
  final int supplierId;
  final String lotName;
  final String coffeeType;
  final String processingMethod;
  final int altitude;
  final double weight;
  final String origin;
  final String status;
  final List<String> certifications;

  const CoffeeLotResponseDto({
    required this.id,
    required this.userId,
    required this.supplierId,
    required this.lotName,
    required this.coffeeType,
    required this.processingMethod,
    required this.altitude,
    required this.weight,
    required this.origin,
    required this.status,
    required this.certifications,
  });

  factory CoffeeLotResponseDto.fromJson(Map<String, dynamic> json) {
    final certs = <String>[];
    final rawCerts = json['certifications'];
    if (rawCerts is List) {
      for (final item in rawCerts) {
        if (item is String) certs.add(item);
      }
    }

    int toInt(dynamic val) {
      if (val is num) return val.toInt();
      return int.tryParse('$val') ?? 0;
    }

    double toDouble(dynamic val) {
      if (val is num) return val.toDouble();
      return double.tryParse('$val') ?? 0.0;
    }

    final rawId = json['id'] ?? json['coffeeLotId'];
    final rawAltitude = json['altitude'] ?? json['altitudeMeters'];
    final rawWeight = json['weight'] ?? json['remainingWeight'];

    return CoffeeLotResponseDto(
      id: toInt(rawId),
      userId: toInt(json['userId']),
      supplierId: toInt(json['supplierId']),
      lotName: (json['lotName'] as String?) ?? '',
      coffeeType: (json['coffeeType'] as String?) ?? '',
      processingMethod: (json['processingMethod'] as String?) ?? '',
      altitude: toInt(rawAltitude),
      weight: toDouble(rawWeight),
      origin: (json['origin'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'ACTIVE',
      certifications: certs,
    );
  }
}
