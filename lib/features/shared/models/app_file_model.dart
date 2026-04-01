import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AppFileModel {
  final String name;
  final String path;
  final int size;

  const AppFileModel({
    required this.name,
    required this.path,
    required this.size,
  });
}

Future<AppFileModel> mapXFile(XFile file) async {
  final size = await File(file.path).length();
  return AppFileModel(
    name: file.name,
    path: file.path,
    size: size,
  );
}