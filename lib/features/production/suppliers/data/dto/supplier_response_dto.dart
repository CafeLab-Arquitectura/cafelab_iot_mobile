class SupplierResponseDto {
  final int id;
  final int userId;
  final String name;
  final String email;
  final int phone;
  final String location;
  final List<String> specialties;

  const SupplierResponseDto({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.specialties,
  });

  factory SupplierResponseDto.fromJson(Map<String, dynamic> json) {
    final rawSpecs = json['specialties'] ?? json['specialities'];
    final specs = <String>[];
    if (rawSpecs is List) {
      for (final item in rawSpecs) {
        if (item is String) specs.add(item);
      }
    }

    int toInt(dynamic val) {
      if (val is num) return val.toInt();
      return int.tryParse('$val') ?? 0;
    }

    final rawId = json['id'] ?? json['supplierId'];
    return SupplierResponseDto(
      id: toInt(rawId),
      userId: toInt(json['userId']),
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: toInt(json['phone']),
      location: (json['location'] as String?) ?? '',
      specialties: specs,
    );
  }
}
