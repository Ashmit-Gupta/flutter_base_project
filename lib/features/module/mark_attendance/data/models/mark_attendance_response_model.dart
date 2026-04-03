import 'package:basic_project_setup/core/parsing/json_strict_parser.dart';

class MarkAttendanceResponseModel {
  final bool success;
  final String message;
  final MarkAttendanceDataModel data;

  const MarkAttendanceResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MarkAttendanceResponseModel.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    final success = requireField<bool>(map, 'success', 'success');
    final message = requireField<String>(map, 'message', 'message');
    final dataMap = requireField<Map<String, dynamic>>(map, 'data', 'data');
    return MarkAttendanceResponseModel(
      success: success,
      message: message,
      data: MarkAttendanceDataModel.fromJson(dataMap),
    );
  }
}

class MarkAttendanceDataModel {
  final int logId;
  final String createdAt;
  final bool recognized;
  final String status;
  final MarkAttendanceEmployeeModel? employee;
  final MarkAttendanceFaceResultModel faceResult;
  final MarkAttendanceFaceImageModel faceImage;
  final String? attendanceAction;
  final Map<String, dynamic>? attendance;

  const MarkAttendanceDataModel({
    required this.logId,
    required this.createdAt,
    required this.recognized,
    required this.status,
    required this.employee,
    required this.faceResult,
    required this.faceImage,
    required this.attendanceAction,
    required this.attendance,
  });

  factory MarkAttendanceDataModel.fromJson(Map<String, dynamic> json) {
    final employeeMap = _asNullableMap(json['employee'], 'data.employee');
    final attendanceActionValue = _asNullableStringOrMapName(
      json['attendance_action'],
      'data.attendance_action',
    );
    final attendanceMap = _asNullableMap(json['attendance'], 'data.attendance');

    return MarkAttendanceDataModel(
      logId: requireField<int>(json, 'log_id', 'data.log_id'),
      createdAt: requireField<String>(json, 'created_at', 'data.created_at'),
      recognized: requireField<bool>(json, 'recognized', 'data.recognized'),
      status: requireField<String>(json, 'status', 'data.status'),
      employee: employeeMap == null
          ? null
          : MarkAttendanceEmployeeModel.fromJson(employeeMap),
      faceResult: MarkAttendanceFaceResultModel.fromJson(
        requireField<Map<String, dynamic>>(
          json,
          'face_result',
          'data.face_result',
        ),
      ),
      faceImage: MarkAttendanceFaceImageModel.fromJson(
        requireField<Map<String, dynamic>>(json, 'face_image', 'data.face_image'),
      ),
      attendanceAction: attendanceActionValue,
      attendance: attendanceMap,
    );
  }
}

class MarkAttendanceEmployeeModel {
  final String? empCode;
  final String? name;

  const MarkAttendanceEmployeeModel({
    required this.empCode,
    required this.name,
  });

  factory MarkAttendanceEmployeeModel.fromJson(Map<String, dynamic> json) {
    return MarkAttendanceEmployeeModel(
      empCode: _asNullableString(
        json['emp_code'] ?? json['employee_code'],
        'data.employee.emp_code|employee_code',
      ),
      name: _asNullableString(json['name'], 'data.employee.name'),
    );
  }
}

class MarkAttendanceFaceResultModel {
  final bool verified;
  final String name;
  final double confidence;
  final int totalFaces;
  final MarkAttendanceFaceRawModel raw;

  const MarkAttendanceFaceResultModel({
    required this.verified,
    required this.name,
    required this.confidence,
    required this.totalFaces,
    required this.raw,
  });

  factory MarkAttendanceFaceResultModel.fromJson(Map<String, dynamic> json) {
    return MarkAttendanceFaceResultModel(
      verified: requireField<bool>(json, 'verified', 'data.face_result.verified'),
      name: requireField<String>(json, 'name', 'data.face_result.name'),
      confidence: _asDouble(
        requireField<num>(json, 'confidence', 'data.face_result.confidence'),
      ),
      totalFaces: requireField<int>(
        json,
        'total_faces',
        'data.face_result.total_faces',
      ),
      raw: MarkAttendanceFaceRawModel.fromJson(
        requireField<Map<String, dynamic>>(json, 'raw', 'data.face_result.raw'),
      ),
    );
  }
}

class MarkAttendanceFaceRawModel {
  final int totalFaces;
  final List<MarkAttendanceFaceCandidateModel> faces;

  const MarkAttendanceFaceRawModel({
    required this.totalFaces,
    required this.faces,
  });

  factory MarkAttendanceFaceRawModel.fromJson(Map<String, dynamic> json) {
    final facesRaw = requireField<List<dynamic>>(
      json,
      'faces',
      'data.face_result.raw.faces',
    );
    final faces = facesRaw
        .map((e) => MarkAttendanceFaceCandidateModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    return MarkAttendanceFaceRawModel(
      totalFaces: requireField<int>(
        json,
        'total_faces',
        'data.face_result.raw.total_faces',
      ),
      faces: faces,
    );
  }
}

class MarkAttendanceFaceCandidateModel {
  final String? empCode;
  final String name;
  final double score;

  const MarkAttendanceFaceCandidateModel({
    required this.empCode,
    required this.name,
    required this.score,
  });

  factory MarkAttendanceFaceCandidateModel.fromJson(Map<String, dynamic> json) {
    return MarkAttendanceFaceCandidateModel(
      empCode: _asNullableString(
        json['emp_code'],
        'data.face_result.raw.faces[].emp_code',
      ),
      name: requireField<String>(json, 'name', 'data.face_result.raw.faces[].name'),
      score: _asDouble(
        requireField<num>(json, 'score', 'data.face_result.raw.faces[].score'),
      ),
    );
  }
}

class MarkAttendanceFaceImageModel {
  final String storage;
  final String key;
  final String url;
  final String contentType;
  final int sizeBytes;

  const MarkAttendanceFaceImageModel({
    required this.storage,
    required this.key,
    required this.url,
    required this.contentType,
    required this.sizeBytes,
  });

  factory MarkAttendanceFaceImageModel.fromJson(Map<String, dynamic> json) {
    return MarkAttendanceFaceImageModel(
      storage: requireField<String>(json, 'storage', 'data.face_image.storage'),
      key: requireField<String>(json, 'key', 'data.face_image.key'),
      url: requireField<String>(json, 'url', 'data.face_image.url'),
      contentType: requireField<String>(
        json,
        'content_type',
        'data.face_image.content_type',
      ),
      sizeBytes: requireField<int>(json, 'size_bytes', 'data.face_image.size_bytes'),
    );
  }
}

Map<String, dynamic>? _asNullableMap(dynamic value, String path) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  throw StateError('Expected Map<String, dynamic> or null at $path');
}

String? _asNullableString(dynamic value, String path) {
  if (value == null) return null;
  if (value is String) return value;
  throw StateError('Expected String or null at $path');
}

String? _asNullableStringOrMapName(dynamic value, String path) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map<String, dynamic>) {
    final name = value['name'];
    if (name == null) return null;
    if (name is String) return name;
    throw StateError('Expected "name" to be String at $path');
  }
  throw StateError('Expected String, Map<String,dynamic>, or null at $path');
}

double _asDouble(num value) => value.toDouble();
