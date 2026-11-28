import 'dart:convert';

import 'package:cafelab_iot_mobile/features/auth/data/user_session_storage.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/data/dto/create_coffee_lot_request_dto.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/data/dto/update_coffee_lot_request_dto.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/create_coffee_lot_input.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/update_coffee_lot_input.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/data/dto/create_roast_profile_request_dto.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/data/dto/create_supplier_request_dto.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/create_supplier_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserSessionStorage.extractUserIdFromJwt', () {
    String makeJwt(Map<String, dynamic> claims) {
      final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'}))).replaceAll('=', '');
      final payload = base64Url.encode(utf8.encode(jsonEncode(claims))).replaceAll('=', '');
      return '$header.$payload.signature';
    }

    test('extracts userId claim', () {
      final jwt = makeJwt({'sub': 'test@cafelab.com', 'userId': 15});
      expect(UserSessionStorage.extractUserIdFromJwt(jwt), 15);
    });

    test('extracts id claim when userId is absent', () {
      final jwt = makeJwt({'sub': 'test@cafelab.com', 'id': 42});
      expect(UserSessionStorage.extractUserIdFromJwt(jwt), 42);
    });

    test('extracts numeric sub claim when id and userId are absent', () {
      final jwt = makeJwt({'sub': 99});
      expect(UserSessionStorage.extractUserIdFromJwt(jwt), 99);
    });

    test('extracts numeric string sub claim', () {
      final jwt = makeJwt({'sub': '77'});
      expect(UserSessionStorage.extractUserIdFromJwt(jwt), 77);
    });

    test('returns null for corrupt or non-jwt string', () {
      expect(UserSessionStorage.extractUserIdFromJwt('not-a-token'), isNull);
      expect(UserSessionStorage.extractUserIdFromJwt(''), isNull);
    });
  });

  group('CreateCoffeeLotRequestDto userId handling', () {
    test('serializes with explicit userId', () {
      const input = CreateCoffeeLotInput(
        userId: 5,
        supplierId: 2,
        lotName: 'Lote Bourbon',
        coffeeType: 'Typica',
        processingMethod: 'Lavado',
        altitude: 1700,
        weight: 120.5,
        origin: 'Cajamarca',
        status: 'ACTIVE',
        certifications: ['ORGANIC'],
      );

      final dto = CreateCoffeeLotRequestDto.fromInput(input);
      final json = dto.toJson();

      expect(json['userId'], 5);
      expect(json['supplierId'], 2);
      expect(json['altitudeMeters'], 1700.0);
      expect(json['initialWeight'], 120.5);
    });

    test('uses fallbackUserId when input userId is absent', () {
      const input = CreateCoffeeLotInput(
        supplierId: 1,
        lotName: 'Lote Geisha',
        coffeeType: 'Geisha',
        processingMethod: 'Natural',
        altitude: 1900,
        weight: 50.0,
        origin: 'Cusco',
        status: 'ACTIVE',
        certifications: [],
      );

      final dto = CreateCoffeeLotRequestDto.fromInput(input);
      final json = dto.toJson(fallbackUserId: 8);

      expect(json['userId'], 8);
    });

    test('defaults to 1 when both userId and fallbackUserId are absent or non-positive', () {
      const input = CreateCoffeeLotInput(
        supplierId: 1,
        lotName: 'Lote Caturra',
        coffeeType: 'Caturra',
        processingMethod: 'Honey',
        altitude: 1500,
        weight: 80.0,
        origin: 'Junin',
        status: 'ACTIVE',
        certifications: [],
      );

      final dto = CreateCoffeeLotRequestDto.fromInput(input);
      final json = dto.toJson(fallbackUserId: 0);

      expect(json['userId'], 1);
    });
  });

  group('UpdateCoffeeLotRequestDto userId handling', () {
    test('includes userId and supplierId when available', () {
      const input = UpdateCoffeeLotInput(
        supplierId: 3,
        userId: 12,
        lotName: 'Lote Actualizado',
        coffeeType: 'Typica',
        processingMethod: 'Lavado',
        altitude: 1600,
        weight: 100.0,
        origin: 'Villa Rica',
        status: 'ACTIVE',
        certifications: [],
      );

      final dto = UpdateCoffeeLotRequestDto.fromInput(input);
      final json = dto.toJson();

      expect(json['userId'], 12);
      expect(json['supplierId'], 3);
    });
  });

  group('CreateSupplierRequestDto userId handling', () {
    test('serializes with effective positive userId', () {
      const input = CreateSupplierInput(
        name: 'Finca El Paraiso',
        email: 'paraiso@cafe.com',
        phone: 987654321,
        location: 'Jaen',
        specialties: ['Specialty Coffee'],
      );

      final dto = CreateSupplierRequestDto.fromInput(input);
      final json = dto.toJson(fallbackUserId: 4);

      expect(json['userId'], 4);
      expect(json['name'], 'Finca El Paraiso');
      expect(json['status'], 'ACTIVE');
    });
  });

  group('CreateRoastProfileRequestDto userId handling', () {
    test('serializes with userId and default sensory scores', () {
      const dto = CreateRoastProfileRequestDto(
        name: 'Curva Espresso',
        type: 'Medio',
        duration: 720,
        tempStart: 180.0,
        tempEnd: 215.0,
        lot: 10,
      );

      final json = dto.toJson(fallbackUserId: 3);

      expect(json['userId'], 3);
      expect(json['coffeeLotId'], 10);
      expect(json['acidity'], 50);
      expect(json['sweetness'], 50);
      expect(json['body'], 50);
    });
  });
}
