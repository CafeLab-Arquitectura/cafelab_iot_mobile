class AutofillFieldDto<T> {
  const AutofillFieldDto({
    this.value,
    this.confidence,
  });

  final T? value;
  final double? confidence;

  factory AutofillFieldDto.fromJson(
    Map<String, dynamic>? json,
    T? Function(dynamic raw) parseValue,
  ) {
    if (json == null) {
      return const AutofillFieldDto();
    }
    final rawVal = json['value'];
    final rawConf = json['confidence'];
    return AutofillFieldDto(
      value: rawVal != null ? parseValue(rawVal) : null,
      confidence: rawConf is num ? rawConf.toDouble() : null,
    );
  }
}

class AutofillWarningDto {
  const AutofillWarningDto({
    required this.field,
    required this.code,
    required this.message,
  });

  final String field;
  final String code;
  final String message;

  factory AutofillWarningDto.fromJson(Map<String, dynamic> json) {
    return AutofillWarningDto(
      field: (json['field'] as String?) ?? '',
      code: (json['code'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
    );
  }
}

class DocumentAutofillFieldsDto {
  const DocumentAutofillFieldsDto({
    this.lotName = const AutofillFieldDto(),
    this.supplierName = const AutofillFieldDto(),
    this.coffeeType = const AutofillFieldDto(),
    this.origin = const AutofillFieldDto(),
    this.processingMethod = const AutofillFieldDto(),
    this.altitudeMeters = const AutofillFieldDto(),
    this.initialWeight = const AutofillFieldDto(),
    this.certifications = const AutofillFieldDto(),
  });

  final AutofillFieldDto<String> lotName;
  final AutofillFieldDto<String> supplierName;
  final AutofillFieldDto<String> coffeeType;
  final AutofillFieldDto<String> origin;
  final AutofillFieldDto<String> processingMethod;
  final AutofillFieldDto<double> altitudeMeters;
  final AutofillFieldDto<double> initialWeight;
  final AutofillFieldDto<List<String>> certifications;

  factory DocumentAutofillFieldsDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DocumentAutofillFieldsDto();
    }

    return DocumentAutofillFieldsDto(
      lotName: AutofillFieldDto.fromJson(
        json['lotName'] as Map<String, dynamic>?,
        (raw) => raw.toString(),
      ),
      supplierName: AutofillFieldDto.fromJson(
        json['supplierName'] as Map<String, dynamic>?,
        (raw) => raw.toString(),
      ),
      coffeeType: AutofillFieldDto.fromJson(
        json['coffeeType'] as Map<String, dynamic>?,
        (raw) => raw.toString(),
      ),
      origin: AutofillFieldDto.fromJson(
        json['origin'] as Map<String, dynamic>?,
        (raw) => raw.toString(),
      ),
      processingMethod: AutofillFieldDto.fromJson(
        json['processingMethod'] as Map<String, dynamic>?,
        (raw) => raw.toString(),
      ),
      altitudeMeters: AutofillFieldDto.fromJson(
        json['altitudeMeters'] as Map<String, dynamic>?,
        (raw) => raw is num ? raw.toDouble() : double.tryParse(raw.toString()),
      ),
      initialWeight: AutofillFieldDto.fromJson(
        json['initialWeight'] as Map<String, dynamic>?,
        (raw) => raw is num ? raw.toDouble() : double.tryParse(raw.toString()),
      ),
      certifications: AutofillFieldDto.fromJson(
        json['certifications'] as Map<String, dynamic>?,
        (raw) {
          if (raw is List) {
            return raw.map((e) => e.toString()).toList();
          }
          return <String>[];
        },
      ),
    );
  }
}

class DocumentAutofillResponseDto {
  const DocumentAutofillResponseDto({
    this.extractionId,
    this.cached = false,
    this.fields = const DocumentAutofillFieldsDto(),
    this.warnings = const <AutofillWarningDto>[],
  });

  final int? extractionId;
  final bool cached;
  final DocumentAutofillFieldsDto fields;
  final List<AutofillWarningDto> warnings;

  factory DocumentAutofillResponseDto.fromJson(Map<String, dynamic> json) {
    final rawWarnings = json['warnings'];
    final warningsList = <AutofillWarningDto>[];
    if (rawWarnings is List) {
      for (final item in rawWarnings) {
        if (item is Map<String, dynamic>) {
          warningsList.add(AutofillWarningDto.fromJson(item));
        }
      }
    }

    return DocumentAutofillResponseDto(
      extractionId: json['extractionId'] is num
          ? (json['extractionId'] as num).toInt()
          : int.tryParse(json['extractionId']?.toString() ?? ''),
      cached: json['cached'] == true,
      fields: DocumentAutofillFieldsDto.fromJson(
        json['fields'] as Map<String, dynamic>?,
      ),
      warnings: warningsList,
    );
  }
}
