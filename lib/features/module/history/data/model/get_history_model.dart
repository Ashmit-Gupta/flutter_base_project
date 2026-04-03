import 'package:basic_project_setup/core/parsing/json_strict_parser.dart';

class GetHistoryModel {
  const GetHistoryModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final GetHistoryDataModel data;

  factory GetHistoryModel.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return GetHistoryModel(
      success: requireField<bool>(map, 'success', 'success'),
      message: requireField<String>(map, 'message', 'message'),
      data: GetHistoryDataModel.fromJson(
        requireField<Map<String, dynamic>>(map, 'data', 'data'),
      ),
    );
  }
}

class GetHistoryDataModel {
  const GetHistoryDataModel({
    required this.items,
    required this.meta,
  });

  final List<GetHistoryItemModel> items;
  final GetHistoryMetaModel meta;

  factory GetHistoryDataModel.fromJson(Map<String, dynamic> json) {
    final itemsRaw = requireField<List<dynamic>>(json, 'items', 'items');
    final items = itemsRaw
        .asMap()
        .entries
        .map((entry) {
          final item = entry.value as Map<String, dynamic>;
          return GetHistoryItemModel.fromJson(item);
        })
        .toList(growable: false);

    return GetHistoryDataModel(
      items: items,
      meta: GetHistoryMetaModel.fromJson(
        requireField<Map<String, dynamic>>(json, 'meta', 'meta'),
      ),
    );
  }
}

class GetHistoryItemModel {
  const GetHistoryItemModel({
    required this.id,
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.status,
    required this.confidence,
    required this.metadata,
    required this.createdAt,
  });

  final int id;
  final int? employeeId;
  final String? employeeCode;
  final String? employeeName;
  final String status;
  final double confidence;
  final GetHistoryMetadataModel metadata;
  final String createdAt;

  factory GetHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return GetHistoryItemModel(
      id: requireField<int>(json, 'id', 'id'),
      employeeId: json['employee_id'] as int?,
      employeeCode: json['employee_code'] as String?,
      employeeName: json['employee_name'] as String?,
      status: requireField<String>(json, 'status', 'status'),
      confidence: (requireField<num>(json, 'confidence', 'confidence')).toDouble(),
      metadata: GetHistoryMetadataModel.fromJson(
        requireField<Map<String, dynamic>>(json, 'metadata', 'metadata'),
      ),
      createdAt: requireField<String>(json, 'created_at', 'created_at'),
    );
  }
}

class GetHistoryMetadataModel {
  const GetHistoryMetadataModel({
    required this.extra,
    required this.location,
    required this.deviceId,
    required this.faceImage,
    required this.faceResult,
  });

  final dynamic extra;
  final GetHistoryLocationModel? location;
  final String? deviceId;
  final GetHistoryFaceImageModel? faceImage;
  final GetHistoryFaceResultModel? faceResult;

  factory GetHistoryMetadataModel.fromJson(Map<String, dynamic> json) {
    return GetHistoryMetadataModel(
      extra: json['extra'],
      location: _mapOrNull(json['location']) == null
          ? null
          : GetHistoryLocationModel.fromJson(
              _mapOrNull(json['location'])!,
            ),
      deviceId: json['device_id'] as String?,
      faceImage: _mapOrNull(json['face_image']) == null
          ? null
          : GetHistoryFaceImageModel.fromJson(
              _mapOrNull(json['face_image'])!,
            ),
      faceResult: _mapOrNull(json['face_result']) == null
          ? null
          : GetHistoryFaceResultModel.fromJson(
              _mapOrNull(json['face_result'])!,
            ),
    );
  }
}

class GetHistoryLocationModel {
  const GetHistoryLocationModel({
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  final double latitude;
  final double longitude;
  final String locationName;

  factory GetHistoryLocationModel.fromJson(Map<String, dynamic> json) {
    return GetHistoryLocationModel(
      latitude: (requireField<num>(json, 'latitude', 'latitude')).toDouble(),
      longitude: (requireField<num>(json, 'longitude', 'longitude')).toDouble(),
      locationName: requireField<String>(json, 'location_name', 'location_name'),
    );
  }
}

class GetHistoryFaceImageModel {
  const GetHistoryFaceImageModel({
    required this.key,
    required this.url,
    required this.storage,
    required this.sizeBytes,
    required this.contentType,
  });

  final String key;
  final String url;
  final String storage;
  final int sizeBytes;
  final String contentType;

  factory GetHistoryFaceImageModel.fromJson(Map<String, dynamic> json) {
    return GetHistoryFaceImageModel(
      key: requireField<String>(json, 'key', 'key'),
      url: requireField<String>(json, 'url', 'url'),
      storage: requireField<String>(json, 'storage', 'storage'),
      sizeBytes: requireField<int>(json, 'size_bytes', 'size_bytes'),
      contentType: requireField<String>(json, 'content_type', 'content_type'),
    );
  }
}

class GetHistoryFaceResultModel {
  const GetHistoryFaceResultModel({
    required this.raw,
    required this.name,
    required this.empCode,
    required this.verified,
    required this.confidence,
    required this.totalFaces,
  });

  final GetHistoryFaceResultRawModel raw;
  final String name;
  final String? empCode;
  final bool verified;
  final double confidence;
  final int totalFaces;

  factory GetHistoryFaceResultModel.fromJson(Map<String, dynamic> json) {
    return GetHistoryFaceResultModel(
      raw: GetHistoryFaceResultRawModel.fromJson(
        requireField<Map<String, dynamic>>(json, 'raw', 'raw'),
      ),
      name: requireField<String>(json, 'name', 'name'),
      empCode: json['emp_code'] as String?,
      verified: requireField<bool>(json, 'verified', 'verified'),
      confidence: (requireField<num>(json, 'confidence', 'confidence')).toDouble(),
      totalFaces: requireField<int>(json, 'total_faces', 'total_faces'),
    );
  }
}

class GetHistoryFaceResultRawModel {
  const GetHistoryFaceResultRawModel({
    required this.faces,
    required this.totalFaces,
  });

  final List<GetHistoryFaceResultRawFaceModel> faces;
  final int totalFaces;

  factory GetHistoryFaceResultRawModel.fromJson(Map<String, dynamic> json) {
    final facesRaw = requireField<List<dynamic>>(json, 'faces', 'faces');
    final faces = facesRaw
        .map((face) => GetHistoryFaceResultRawFaceModel.fromJson(
              face as Map<String, dynamic>,
            ))
        .toList(growable: false);

    return GetHistoryFaceResultRawModel(
      faces: faces,
      totalFaces: requireField<int>(json, 'total_faces', 'total_faces'),
    );
  }
}

class GetHistoryFaceResultRawFaceModel {
  const GetHistoryFaceResultRawFaceModel({
    required this.name,
    required this.score,
    required this.empCode,
  });

  final String name;
  final double score;
  final String? empCode;

  factory GetHistoryFaceResultRawFaceModel.fromJson(Map<String, dynamic> json) {
    return GetHistoryFaceResultRawFaceModel(
      name: requireField<String>(json, 'name', 'name'),
      score: (requireField<num>(json, 'score', 'score')).toDouble(),
      empCode: json['emp_code'] as String?,
    );
  }
}

class GetHistoryMetaModel {
  const GetHistoryMetaModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.startDate,
    required this.endDate,
  });

  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final String startDate;
  final String endDate;

  factory GetHistoryMetaModel.fromJson(Map<String, dynamic> json) {
    return GetHistoryMetaModel(
      total: requireField<int>(json, 'total', 'total'),
      page: requireField<int>(json, 'page', 'page'),
      limit: requireField<int>(json, 'limit', 'limit'),
      totalPages: requireField<int>(json, 'total_pages', 'total_pages'),
      startDate: requireField<String>(json, 'start_date', 'start_date'),
      endDate: requireField<String>(json, 'end_date', 'end_date'),
    );
  }
}

Map<String, dynamic>? _mapOrNull(dynamic value) {
  if (value == null) return null;
  return value as Map<String, dynamic>;
}
