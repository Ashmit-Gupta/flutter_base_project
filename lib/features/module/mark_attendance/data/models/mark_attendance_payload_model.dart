/// Payload for [MarkAttendanceEndpoint.markAttendance] (multipart form-data).
///
/// - [faceImagePath] is the local file path used with `MultipartFile.fromFile`
///   under the form field name [fieldFaceImage].
/// - [location] is sent as text fields (flattened to latitude/longitude/location_name).
class MarkAttendancePayloadModel {
  const MarkAttendancePayloadModel({
    required this.faceImagePath,
    required this.location,
  });

  /// Local path to the captured face image file.
  final String faceImagePath;

  /// Location payload (lat/long/name).
  final MarkAttendanceLocationPayload location;

  /// Form field names matching the API / Postman collection.
  static const fieldFaceImage = 'face_image';
  static const fieldLatitude = 'latitude';
  static const fieldLongitude = 'longitude';
  static const fieldLocationName = 'location_name';

  /// JSON-serializable map of the **text** fields only.
  ///
  /// The image is binary and is not embedded here; send it as multipart
  /// `face_image` using [faceImagePath] with `MultipartFile.fromFile`.
  Map<String, dynamic> toJson() => <String, dynamic>{
        ...location.toJson(),
      };

  /// All non-file keys and values for logging or metadata (excludes file path).
  Map<String, String> toTextFields() => <String, String>{
        ...location.toTextFields(),
      };
}

class MarkAttendanceLocationPayload {
  const MarkAttendanceLocationPayload({
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  final double latitude;
  final double longitude;
  final String locationName;

  Map<String, dynamic> toJson() => <String, dynamic>{
        MarkAttendancePayloadModel.fieldLatitude: latitude,
        MarkAttendancePayloadModel.fieldLongitude: longitude,
        MarkAttendancePayloadModel.fieldLocationName: locationName,
      };

  Map<String, String> toTextFields() => <String, String>{
        MarkAttendancePayloadModel.fieldLatitude: latitude.toString(),
        MarkAttendancePayloadModel.fieldLongitude: longitude.toString(),
        MarkAttendancePayloadModel.fieldLocationName: locationName,
      };
}
