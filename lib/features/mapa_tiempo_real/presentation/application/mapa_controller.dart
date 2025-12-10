import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapaController {
  LatLng? userLocation;
  List<LatLng> locationHistory = [];
  StreamSubscription<Position>? positionStreamSub;

  // Callback para animar el mapa cuando hay cambios
  void Function(LatLng)? onLocationUpdated;

  // Posición inicial por defecto (ejemplo Cuenca, Ecuador)
  static final LatLng initialLatLng = LatLng(-2.90055, -79.00453);

  Future<bool> _ensurePermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> initLocationAndListen(void Function() onUpdate) async {
    try {
      final ok = await _ensurePermissions();
      if (!ok) return null;

      // Posición inicial
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      userLocation = LatLng(position.latitude, position.longitude);
      locationHistory.add(userLocation!);
      onLocationUpdated?.call(userLocation!);
      onUpdate();

      // Stream en tiempo real
      positionStreamSub?.cancel();
      positionStreamSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen((pos) {
            userLocation = LatLng(pos.latitude, pos.longitude);
            locationHistory.add(userLocation!);
            onLocationUpdated?.call(userLocation!);
            onUpdate();
          });

      return position;
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
    }
  }

  void dispose() {
    positionStreamSub?.cancel();
  }
}
