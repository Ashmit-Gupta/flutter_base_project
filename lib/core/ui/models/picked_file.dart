import 'package:equatable/equatable.dart';

/// Framework-agnostic picked file descriptor for [FilePickerWidget].
/// Lives in core so UI does not depend on feature-layer models.
class PickedFile extends Equatable {
  const PickedFile({
    required this.name,
    required this.path,
    required this.size,
  });

  final String name;
  final String path;
  final int size;

  @override
  List<Object?> get props => [name, path, size];
}
