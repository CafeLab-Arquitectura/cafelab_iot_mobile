import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cafelab_iot_mobile/core/config/api_config.dart';
import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/data/dto/document_autofill_response_dto.dart';
import 'package:cafelab_iot_mobile/features/production/shared/api_error_response.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class DocumentAutofillApiService {
  DocumentAutofillApiService({
    http.Client? client,
    TokenStorageService? tokenStorage,
  })  : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  final http.Client _client;
  final TokenStorageService _tokenStorage;

  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedExtensions = <String>[
    '.jpg',
    '.jpeg',
    '.png',
    '.pdf',
  ];

  Uri get _endpointUri =>
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documentAutofillBasePath}');

  MediaType _resolveMediaType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (lower.endsWith('.pdf')) {
      return MediaType('application', 'pdf');
    }
    return MediaType('image', 'jpeg');
  }

  void validateFile({required String filename, required int sizeInBytes}) {
    final lower = filename.toLowerCase();
    final hasAllowedExtension =
        allowedExtensions.any((ext) => lower.endsWith(ext));
    if (!hasAllowedExtension) {
      throw const ProductionApiException(
        'Formato no permitido. Usa JPG, PNG o PDF.',
        statusCode: HttpStatus.badRequest,
        errorResponse: ApiErrorResponse(
          message: 'Formato no permitido. Usa JPG, PNG o PDF.',
          errors: <ApiFieldValidationError>[],
        ),
      );
    }

    if (sizeInBytes > maxFileSizeBytes) {
      throw const ProductionApiException(
        'El archivo supera el máximo de 10 MB.',
        statusCode: HttpStatus.badRequest,
        errorResponse: ApiErrorResponse(
          message: 'El archivo supera el máximo de 10 MB.',
          errors: <ApiFieldValidationError>[],
        ),
      );
    }
  }

  Future<DocumentAutofillResponseDto> autofillFromFile({
    required File file,
  }) async {
    final filename = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : 'guia_remision.jpg';
    final length = await file.length();
    validateFile(filename: filename, sizeInBytes: length);

    final bytes = await file.readAsBytes();
    return autofillFromBytes(
      bytes: bytes,
      filename: filename,
    );
  }

  Future<DocumentAutofillResponseDto> autofillFromBytes({
    required Uint8List bytes,
    required String filename,
  }) async {
    validateFile(filename: filename, sizeInBytes: bytes.length);

    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const ProductionApiException(
        'No hay token de sesión disponible.',
        statusCode: HttpStatus.unauthorized,
      );
    }

    final request = http.MultipartRequest('POST', _endpointUri);
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

    final mediaType = _resolveMediaType(filename);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: mediaType,
      ),
    );

    if (kDebugMode) {
      debugPrint('[DocumentAutofillApiService] POST $_endpointUri ($filename, ${bytes.length} bytes, $mediaType)');
    }

    http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await _client.send(request).timeout(
            const Duration(seconds: 45),
            onTimeout: () => throw TimeoutException('Tiempo de espera agotado'),
          );
    } on SocketException catch (e) {
      throw ProductionApiException(
        'No se pudo conectar con el servidor: ${e.message}',
        statusCode: 0,
      );
    } on TimeoutException {
      throw const ProductionApiException(
        'El servidor tardó demasiado en responder. Intenta de nuevo.',
        statusCode: HttpStatus.gatewayTimeout,
      );
    } catch (e) {
      throw ProductionApiException(
        'Error de conexión: $e',
        statusCode: 0,
      );
    }

    final responseBody = await streamedResponse.stream.bytesToString();

    if (kDebugMode) {
      debugPrint('[DocumentAutofillApiService] Status: ${streamedResponse.statusCode}');
      debugPrint('[DocumentAutofillApiService] Body: $responseBody');
    }

    if (streamedResponse.statusCode == HttpStatus.ok) {
      try {
        final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
        return DocumentAutofillResponseDto.fromJson(decoded);
      } catch (e) {
        throw ProductionApiException(
          'Error al procesar la respuesta del servidor: $e',
          statusCode: streamedResponse.statusCode,
        );
      }
    }

    // Handle error codes
    String message = 'No se pudo leer el documento automáticamente. Completa el formulario manualmente.';
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] is String && (decoded['message'] as String).isNotEmpty) {
          message = decoded['message'] as String;
        } else if (decoded['error'] is String && (decoded['error'] as String).isNotEmpty) {
          message = decoded['error'] as String;
        }
      }
    } catch (_) {}

    if (streamedResponse.statusCode == HttpStatus.unauthorized ||
        streamedResponse.statusCode == HttpStatus.forbidden) {
      message = 'Sesión expirada o sin autorización. Inicia sesión nuevamente.';
    }

    throw ProductionApiException(
      message,
      statusCode: streamedResponse.statusCode,
      errorResponse: ApiErrorResponse(
        message: message,
        errors: const <ApiFieldValidationError>[],
      ),
      rawBody: responseBody,
    );
  }
}
