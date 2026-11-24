import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cafelab_iot_mobile/core/config/api_config.dart';
import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/cost_management/data/dto/annul_production_cost_record_request_dto.dart';
import 'package:cafelab_iot_mobile/features/cost_management/data/dto/create_production_cost_record_request_dto.dart';
import 'package:cafelab_iot_mobile/features/cost_management/data/dto/production_cost_record_response_dto.dart';
import 'package:cafelab_iot_mobile/features/cost_management/domain/utils/production_cost_calculator.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductionCostRecordsApiService {
  ProductionCostRecordsApiService({
    http.Client? client,
    TokenStorageService? tokenStorage,
  })  : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  final http.Client _client;
  final TokenStorageService _tokenStorage;
  static const String _localStorageKey = 'cafelab_cost_records_v1';

  Uri get _baseUri =>
      Uri.parse('${ApiConfig.baseUrl}/api/v1/production-cost-records');

  Uri get _costingBatchesUri =>
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.costingBatchesBasePath}');

  Future<Map<String, String>> _headers() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const ProductionApiException(
        'No hay token de sesion disponible.',
        statusCode: 401,
      );
    }
    return {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }

  Future<List<ProductionCostRecordResponseDto>> getAll() async {
    try {
      final response = await _send(method: 'GET', uri: _baseUri);
      if (response.statusCode == HttpStatus.ok) {
        final records = _parseList(response.body);
        await _syncLocalCache(records);
        return records;
      }
    } catch (e) {
      debugPrint('[ProductionCostRecordsApiService] Error conectando a backend remoto: $e');
    }

    // Fallback a almacenamiento local cuando el microservicio Costing no expone el endpoint monolítico
    return await _getLocalRecords();
  }

  Future<ProductionCostRecordResponseDto> getById(int id) async {
    try {
      final response = await _send(
        method: 'GET',
        uri: Uri.parse('${_baseUri.toString()}/$id'),
      );
      if (response.statusCode == HttpStatus.ok) {
        return ProductionCostRecordResponseDto.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
    } catch (_) {}

    final local = await _getLocalRecords();
    return local.firstWhere(
      (r) => r.id == id,
      orElse: () => throw const ProductionApiException(
        'Registro de costo no encontrado',
        statusCode: 404,
      ),
    );
  }

  Future<ProductionCostRecordResponseDto> create(
    CreateProductionCostRecordRequestDto dto,
  ) async {
    // 1. Intentar registrar batch en el microservicio Costing (si está disponible)
    try {
      final batchPayload = jsonEncode({
        'batchName': 'Lote #${dto.coffeeLotId}',
        'registrationDate': DateTime.now().toIso8601String().substring(0, 10),
      });
      await _send(method: 'POST', uri: _costingBatchesUri, body: batchPayload);
    } catch (e) {
      debugPrint('[ProductionCostRecordsApiService] Sync batch en Costing: $e');
    }

    // 2. Intentar endpoint directo si el backend lo soporta
    try {
      final response = await _send(
        method: 'POST',
        uri: _baseUri,
        body: jsonEncode(dto.toJson()),
      );
      if (response.statusCode == HttpStatus.created) {
        final created = ProductionCostRecordResponseDto.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        await _saveLocalRecord(created);
        return created;
      }
    } catch (e) {
      debugPrint('[ProductionCostRecordsApiService] POST remoto no disponible, calculando localmente: $e');
    }

    // 3. Fallback: Calcular métricas idénticas al frontend Angular y guardar localmente
    final totalDirect = dto.rawMaterialsCost + dto.laborCost;
    final totalIndirect = dto.transportCost +
        dto.storageCost +
        dto.processingCost +
        dto.otherIndirectCosts;
    final totalCost = ProductionCostCalculator.grandTotal(
      rawMaterialsCost: dto.rawMaterialsCost,
      laborCost: dto.laborCost,
      transportCost: dto.transportCost,
      storageCost: dto.storageCost,
      processingCost: dto.processingCost,
      otherIndirectCosts: dto.otherIndirectCosts,
    );
    final costPerKg = ProductionCostCalculator.costPerKg(
      grandTotal: totalCost,
      totalKg: dto.totalKg,
    );
    final suggestedPrice = ProductionCostCalculator.suggestedPrice(
      costPerKg: costPerKg,
      marginPercent: dto.marginPercent,
    );
    final potentialMargin = ProductionCostCalculator.potentialMargin(
      suggestedPrice: suggestedPrice,
      costPerKg: costPerKg,
    );

    final generatedId = DateTime.now().millisecondsSinceEpoch;
    final localRecord = ProductionCostRecordResponseDto(
      id: generatedId,
      userId: 1,
      coffeeLotId: dto.coffeeLotId,
      lotName: 'Lote #${dto.coffeeLotId}',
      coffeeType: 'Arábica',
      currency: dto.currency,
      totalKg: dto.totalKg,
      marginPercent: dto.marginPercent,
      rawMaterialsCost: dto.rawMaterialsCost,
      laborCost: dto.laborCost,
      transportCost: dto.transportCost,
      storageCost: dto.storageCost,
      processingCost: dto.processingCost,
      otherIndirectCosts: dto.otherIndirectCosts,
      totalDirectCost: totalDirect,
      totalIndirectCost: totalIndirect,
      totalCost: totalCost,
      costPerKg: costPerKg,
      suggestedPrice: suggestedPrice,
      potentialMargin: potentialMargin,
      status: 'CONFIRMED',
      reason: '',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    await _saveLocalRecord(localRecord);
    return localRecord;
  }

  Future<ProductionCostRecordResponseDto> annul(
    int id,
    AnnulProductionCostRecordRequestDto dto,
  ) async {
    try {
      final response = await _send(
        method: 'POST',
        uri: Uri.parse('${_baseUri.toString()}/$id/annulment'),
        body: jsonEncode(dto.toJson()),
      );
      if (response.statusCode == HttpStatus.ok) {
        final updated = ProductionCostRecordResponseDto.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        await _saveLocalRecord(updated);
        return updated;
      }
    } catch (_) {}

    final records = await _getLocalRecords();
    final index = records.indexWhere((r) => r.id == id);
    if (index >= 0) {
      final current = records[index];
      final updated = ProductionCostRecordResponseDto(
        id: current.id,
        userId: current.userId,
        coffeeLotId: current.coffeeLotId,
        lotName: current.lotName,
        coffeeType: current.coffeeType,
        currency: current.currency,
        totalKg: current.totalKg,
        marginPercent: current.marginPercent,
        rawMaterialsCost: current.rawMaterialsCost,
        laborCost: current.laborCost,
        transportCost: current.transportCost,
        storageCost: current.storageCost,
        processingCost: current.processingCost,
        otherIndirectCosts: current.otherIndirectCosts,
        totalDirectCost: current.totalDirectCost,
        totalIndirectCost: current.totalIndirectCost,
        totalCost: current.totalCost,
        costPerKg: current.costPerKg,
        suggestedPrice: current.suggestedPrice,
        potentialMargin: current.potentialMargin,
        status: 'ANNULLED',
        reason: dto.reason,
        createdAt: current.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
      records[index] = updated;
      await _syncLocalCache(records);
      return updated;
    }

    throw const ProductionApiException(
      'Registro no encontrado para anular',
      statusCode: 404,
    );
  }

  Future<List<ProductionCostRecordResponseDto>> _getLocalRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_localStorageKey);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(ProductionCostRecordResponseDto.fromJson)
            .toList();
      }
    } catch (e) {
      debugPrint('[ProductionCostRecordsApiService] Error leyendo cache local: $e');
    }
    return [];
  }

  Future<void> _syncLocalCache(List<ProductionCostRecordResponseDto> records) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = records.map((r) => r.toJson()).toList();
      await prefs.setString(_localStorageKey, jsonEncode(listJson));
    } catch (_) {}
  }

  Future<void> _saveLocalRecord(ProductionCostRecordResponseDto record) async {
    final list = await _getLocalRecords();
    final index = list.indexWhere((r) => r.id == record.id);
    if (index >= 0) {
      list[index] = record;
    } else {
      list.insert(0, record);
    }
    await _syncLocalCache(list);
  }

  Future<http.Response> _send({
    required String method,
    required Uri uri,
    String? body,
  }) async {
    final headers = await _headers();
    debugPrint('[ProductionCostRecordsApiService] $method $uri');
    if (body != null) {
      debugPrint('[ProductionCostRecordsApiService] body: $body');
    }

    final response = switch (method) {
      'POST' => await _client
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 20)),
      'GET' => await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20)),
      _ => throw const ProductionApiException('Metodo no soportado'),
    };

    debugPrint(
      '[ProductionCostRecordsApiService] status: ${response.statusCode}',
    );
    return response;
  }

  List<ProductionCostRecordResponseDto> _parseList(String body) {
    if (body.trim().isEmpty) return [];
    final decoded = jsonDecode(body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ProductionCostRecordResponseDto.fromJson)
        .toList();
  }
}
