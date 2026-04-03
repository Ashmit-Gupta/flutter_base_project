import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AppLocation {
  final double latitude;
  final double longitude;
  final String name;

  const AppLocation({
    required this.latitude,
    required this.longitude,
    required this.name,
  });
}

abstract class LocationService {
  Future<AppLocation> getCurrentLocation();
}

class LocationServiceImpl implements LocationService {
  @override
  Future<AppLocation> getCurrentLocation() async {
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } on LocationServiceDisabledException {
      throw StateError('Location service is disabled');
    }

    final name = await _reverseGeocodeName(position);
    return AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      name: name,
    );
  }

  Future<String> _reverseGeocodeName(Position position) async {
    try {
      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (places.isEmpty) return 'Unknown location';
      final p = places.first;

      final parts = <String>[
        if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
        if ((p.subAdministrativeArea ?? '').trim().isNotEmpty)
          p.subAdministrativeArea!.trim(),
        if ((p.administrativeArea ?? '').trim().isNotEmpty)
          p.administrativeArea!.trim(),
      ];

      if (parts.isEmpty) return 'Unknown location';
      return parts.join(', ');
    } catch (_) {
      return 'Unknown location';
    }
  }
}

