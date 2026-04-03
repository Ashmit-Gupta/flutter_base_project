/// Domain value object: three face-registration images (paths only).
/// No Flutter imports — portable and unit-testable.
class EmployeeRegistrationPhotos {
  const EmployeeRegistrationPhotos({
    required this.leftProfilePath,
    required this.frontProfilePath,
    required this.rightProfilePath,
  });

  final String leftProfilePath;
  final String frontProfilePath;
  final String rightProfilePath;

  /// `null` if valid; otherwise a user-facing validation message.
  String? validate() {
    for (final p in [leftProfilePath, frontProfilePath, rightProfilePath]) {
      if (p.trim().isEmpty) {
        return 'Please capture all profiles (left, front, right).';
      }
    }
    return null;
  }
}
