class RoastProfileResponseDto {
  final int id;
  final int userId;
  final String name;
  final String type;
  final int duration;
  final double tempStart;
  final double tempEnd;
  final int coffeeLotId;
  final bool isFavorite;

  const RoastProfileResponseDto({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.duration,
    required this.tempStart,
    required this.tempEnd,
    required this.coffeeLotId,
    required this.isFavorite,
  });

  factory RoastProfileResponseDto.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val is num) return val.toInt();
      return int.tryParse('$val') ?? 0;
    }

    double toDouble(dynamic val) {
      if (val is num) return val.toDouble();
      return double.tryParse('$val') ?? 0.0;
    }

    final rawId = json['id'] ?? json['roastProfileId'];
    final rawDuration = json['duration'] ?? json['durationSeconds'];
    final rawTempStart = json['tempStart'] ?? json['temperatureStart'];
    final rawTempEnd = json['tempEnd'] ?? json['temperatureEnd'];

    return RoastProfileResponseDto(
      id: toInt(rawId),
      userId: toInt(json['userId']),
      name: (json['name'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      duration: toInt(rawDuration),
      tempStart: toDouble(rawTempStart),
      tempEnd: toDouble(rawTempEnd),
      coffeeLotId: toInt(json['coffeeLotId']),
      isFavorite: (json['isFavorite'] as bool?) ?? false,
    );
  }
}
