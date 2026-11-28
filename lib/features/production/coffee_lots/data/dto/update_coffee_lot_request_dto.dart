import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/update_coffee_lot_input.dart';

class UpdateCoffeeLotRequestDto {
  final int? supplierId;
  final int? userId;
  final String lotName;
  final String coffeeType;
  final String processingMethod;
  final int altitude;
  final double weight;
  final String origin;
  final String status;
  final List<String> certifications;

  const UpdateCoffeeLotRequestDto({
    this.supplierId,
    this.userId,
    required this.lotName,
    required this.coffeeType,
    required this.processingMethod,
    required this.altitude,
    required this.weight,
    required this.origin,
    required this.status,
    required this.certifications,
  });

  factory UpdateCoffeeLotRequestDto.fromInput(UpdateCoffeeLotInput input) {
    return UpdateCoffeeLotRequestDto(
      supplierId: input.supplierId,
      userId: input.userId,
      lotName: input.lotName,
      coffeeType: input.coffeeType,
      processingMethod: input.processingMethod,
      altitude: input.altitude,
      weight: input.weight,
      origin: input.origin,
      status: input.status,
      certifications: input.certifications,
    );
  }

  Map<String, dynamic> toJson({int? fallbackUserId}) {
    final effectiveUserId = (userId != null && userId! > 0)
        ? userId!
        : ((fallbackUserId != null && fallbackUserId > 0) ? fallbackUserId : 1);

    return {
      if (supplierId != null && supplierId! > 0) ...{
        'supplierId': supplierId,
        'supplier_id': supplierId,
      },
      'userId': effectiveUserId,
      'user_id': effectiveUserId,
      'lotName': lotName,
      'lot_name': lotName,
      'coffeeType': coffeeType,
      'coffee_type': coffeeType,
      'processingMethod': processingMethod,
      'processing_method': processingMethod,
      'altitudeMeters': altitude.toDouble(),
      'altitude': altitude,
      'weight': weight,
      'origin': origin,
      'status': status.isEmpty ? 'ACTIVE' : status,
      'certifications': certifications,
    };
  }
}
