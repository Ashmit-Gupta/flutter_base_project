import 'dart:convert';
import 'dart:io';

import '../../../../shared/models/app_file_model.dart';

class RegisterEmployeeFaceDetectionImagesModel {
  final AppFileModel leftProfile;
  final AppFileModel frontProfile;
  final AppFileModel rightProfile;

  const RegisterEmployeeFaceDetectionImagesModel({
    required this.leftProfile,
    required this.frontProfile,
    required this.rightProfile,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'left_profile': _fileToJson(leftProfile),
      'front_profile': _fileToJson(frontProfile),
      'right_profile': _fileToJson(rightProfile),
    };
  }

  Map<String, String> toBase64Payload() {
    return <String, String>{
      'left': _toBase64(leftProfile.path),
      'center': _toBase64(frontProfile.path),
      'right': _toBase64(rightProfile.path),
    };
  } 

  Map<String, dynamic> _fileToJson(AppFileModel file) {
    return <String, dynamic>{
      'name': file.name,
      'path': file.path,
      'size': file.size,
      'base64': _toBase64(file.path),
    };
  }

  String _toBase64(String path) {
    final bytes = File(path).readAsBytesSync();
    return base64Encode(bytes);
  }
}
