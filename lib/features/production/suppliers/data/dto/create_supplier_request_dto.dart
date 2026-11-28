import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/create_supplier_input.dart';

class CreateSupplierRequestDto {
  final int? userId;
  final String name;
  final String email;
  final int phone;
  final String location;
  final List<String> specialties;

  const CreateSupplierRequestDto({
    this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.specialties,
  });

  factory CreateSupplierRequestDto.fromInput(CreateSupplierInput input) {
    return CreateSupplierRequestDto(
      userId: input.userId,
      name: input.name,
      email: input.email,
      phone: input.phone,
      location: input.location,
      specialties: input.specialties,
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
      'email': email,
      'phone': '$phone',
      'location': location,
      'specialties': specialties,
      'specialities': specialties,
      'status': 'ACTIVE',
    };
  }
}
