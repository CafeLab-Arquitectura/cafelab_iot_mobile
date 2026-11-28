import 'package:cafelab_iot_mobile/features/production/coffee_lots/data/document_autofill_api_service.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/data/dto/document_autofill_response_dto.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DocumentAutofillResponseDto', () {
    test('deserializes complete backend response correctly', () {
      final json = {
        'extractionId': 42,
        'cached': false,
        'fields': {
          'lotName': {'value': 'Lote Especial Villa Rica', 'confidence': 0.95},
          'supplierName': {'value': 'Cooperativa Agraria Cafetalera', 'confidence': 0.88},
          'coffeeType': {'value': 'Arábica', 'confidence': 0.92},
          'origin': {'value': 'Villa Rica, Pasco', 'confidence': 0.9},
          'processingMethod': {'value': 'Lavado', 'confidence': 0.85},
          'altitudeMeters': {'value': 1650, 'confidence': 0.91},
          'initialWeight': {'value': 2500.5, 'confidence': 0.96},
          'certifications': {
            'value': ['FAIR_TRADE', 'ORGANIC'],
            'confidence': 0.82,
          },
        },
        'warnings': [
          {
            'field': 'altitudeMeters',
            'code': 'LOW_CONFIDENCE',
            'message': 'Altitud detectada con baja confianza.',
          }
        ],
      };

      final dto = DocumentAutofillResponseDto.fromJson(json);

      expect(dto.extractionId, 42);
      expect(dto.cached, isFalse);
      expect(dto.fields.lotName.value, 'Lote Especial Villa Rica');
      expect(dto.fields.lotName.confidence, 0.95);
      expect(dto.fields.supplierName.value, 'Cooperativa Agraria Cafetalera');
      expect(dto.fields.coffeeType.value, 'Arábica');
      expect(dto.fields.origin.value, 'Villa Rica, Pasco');
      expect(dto.fields.processingMethod.value, 'Lavado');
      expect(dto.fields.altitudeMeters.value, 1650.0);
      expect(dto.fields.initialWeight.value, 2500.5);
      expect(dto.fields.certifications.value, ['FAIR_TRADE', 'ORGANIC']);
      expect(dto.warnings.length, 1);
      expect(dto.warnings.first.field, 'altitudeMeters');
      expect(dto.warnings.first.code, 'LOW_CONFIDENCE');
      expect(dto.warnings.first.message, 'Altitud detectada con baja confianza.');
    });

    test('handles missing or partial fields gracefully without throwing', () {
      final json = <String, dynamic>{
        'extractionId': null,
        'cached': true,
        'fields': {
          'lotName': {'value': null, 'confidence': null},
          'altitudeMeters': {'value': '1800', 'confidence': null},
        },
        'warnings': <dynamic>[],
      };

      final dto = DocumentAutofillResponseDto.fromJson(json);

      expect(dto.extractionId, isNull);
      expect(dto.cached, isTrue);
      expect(dto.fields.lotName.value, isNull);
      expect(dto.fields.altitudeMeters.value, 1800.0);
      expect(dto.fields.initialWeight.value, isNull);
      expect(dto.fields.certifications.value, isNull);
      expect(dto.warnings, isEmpty);
    });
  });

  group('DocumentAutofillApiService validation', () {
    final service = DocumentAutofillApiService();

    test('accepts valid filenames and sizes', () {
      expect(
        () => service.validateFile(
          filename: 'guia_remision_123.pdf',
          sizeInBytes: 1024 * 500,
        ),
        returnsNormally,
      );

      expect(
        () => service.validateFile(
          filename: 'FOTO_GUIA.JPG',
          sizeInBytes: 1024 * 1024 * 5,
        ),
        returnsNormally,
      );
    });

    test('rejects disallowed file extensions', () {
      expect(
        () => service.validateFile(
          filename: 'documento.docx',
          sizeInBytes: 1024 * 100,
        ),
        throwsA(
          isA<ProductionApiException>().having(
            (e) => e.userMessage,
            'message',
            contains('Formato no permitido'),
          ),
        ),
      );
    });

    test('rejects files larger than 10 MB', () {
      expect(
        () => service.validateFile(
          filename: 'guia_pesada.pdf',
          sizeInBytes: 11 * 1024 * 1024,
        ),
        throwsA(
          isA<ProductionApiException>().having(
            (e) => e.userMessage,
            'message',
            contains('10 MB'),
          ),
        ),
      );
    });
  });
}
