import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatelessWidget {
  const ImagePreviewScreen({super.key, required this.file});

  final PlatformFile file;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (file.bytes != null) {
      image = Image.memory(file.bytes!, fit: BoxFit.contain);
    } else if (file.path != null) {
      image = Image.file(File(file.path!), fit: BoxFit.contain);
    } else {
      image = const Center(child: Text('Unable to preview this image.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(file.name.trim().isEmpty ? 'Preview' : file.name),
      ),
      body: SafeArea(
        child: Center(child: image),
      ),
    );
  }
}
