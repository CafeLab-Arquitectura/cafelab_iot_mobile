import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/create_roast_profile_input.dart';

class CreateRoastProfileRequestDto {
  final int? userId;
  final String name;
  final String type;
  final int duration;
  final double tempStart;
  final double tempEnd;
  final int lot;
  final bool? isFavorite;
  final int? acidity;
  final int? sweetness;
  final int? body;

  const CreateRoastProfileRequestDto({
    this.userId,
    required this.name,
    required this.type,
    required this.duration,
    required this.tempStart,
    required this.tempEnd,
    required this.lot,
    this.isFavorite,
    this.acidity,
    this.sweetness,
    this.body,
  });

  factory CreateRoastProfileRequestDto.fromInput(CreateRoastProfileInput input) {
    return CreateRoastProfileRequestDto(
      name: input.name,
      type: input.type,
      duration: input.duration,
      tempStart: input.tempStart,
      tempEnd: input.tempEnd,
      lot: input.lot,
      isFavorite: input.isFavorite,
    );
  }

  Map<String, dynamic> toJson({int? fallbackUserId}) {
    final effectiveUserId = (userId != null && userId! > 0)
        ? userId!
        : ((fallbackUserId != null && fallbackUserId > 0) ? fallbackUserId : 1);

    return {
      'userId': effectiveUserId,
      'user_id': effectiveUserId,
      'name': name,
      'type': type,
      'duration': duration,
      'durationSeconds': duration,
      'tempStart': tempStart,
      'temperatureStart': tempStart,
      'tempEnd': tempEnd,
      'temperatureEnd': tempEnd,
      'lot': lot,
      'coffeeLotId': lot,
      'isFavorite': isFavorite ?? false,
      'acidity': acidity ?? 50,
      'sweetness': sweetness ?? 50,
      'body': body ?? 50,
    };
  }
}
