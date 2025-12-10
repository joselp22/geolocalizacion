import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../application/mapa_controller.dart';

class MapaTiempoRealPage extends StatefulWidget {
  static const String routeName = '/mapa-tiempo-real';

  const MapaTiempoRealPage({super.key});

  @override
  State<MapaTiempoRealPage> createState() => _MapaTiempoRealPageState();
}

class _MapaTiempoRealPageState extends State<MapaTiempoRealPage>
    with TickerProviderStateMixin {
  final controllerMapa = MapaController();
  bool loading = true;
  String? errorMessage;
  final MapController mapController = MapController();
  double currentZoom = 14;

  @override
  void initState() {
    super.initState();
    controllerMapa.onLocationUpdated = (location) {
      // Animar el mapa cuando se obtiene una nueva ubicación
      mapController.move(location, 16);
      setState(() => currentZoom = 16);
    };
    _init();
  }

  Future<void> _init() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final position = await controllerMapa.initLocationAndListen(() {
        if (mounted) setState(() {});
      });

      if (!mounted) return;

      if (position == null) {
        setState(() {
          errorMessage =
              'No se pudo obtener la ubicación. Verifica que los permisos estén habilitados.';
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error: ${e.toString()}';
          loading = false;
        });
      }
    }
  }

  void _centerOnUserLocation() {
    final userLocation = controllerMapa.userLocation;
    if (userLocation != null) {
      mapController.move(userLocation, 16);
      setState(() => currentZoom = 16);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación no disponible aún'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _resetRotation() {
    mapController.rotate(0);
  }

  void _zoomIn() {
    setState(() => currentZoom = (currentZoom + 1).clamp(1, 18).toDouble());
    mapController.move(mapController.camera.center, currentZoom);
  }

  void _zoomOut() {
    setState(() => currentZoom = (currentZoom - 1).clamp(1, 18).toDouble());
    mapController.move(mapController.camera.center, currentZoom);
  }

  @override
  void dispose() {
    controllerMapa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userLocation = controllerMapa.userLocation;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa en tiempo real'),
        elevation: 2,
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          // Mapa
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: MapaController.initialLatLng,
              initialZoom: 14,
              onMapEvent: (event) {
                if (event is MapEventMove) {
                  setState(() => currentZoom = event.camera.zoom);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.geolocalizacion',
              ),
              if (userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation,
                      width: 80,
                      height: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.person_pin_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Tú',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Error message
          if (errorMessage != null)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.red[100],
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[900]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: TextStyle(
                              color: Colors.red[900],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Loading indicator
          if (loading && errorMessage == null)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Obteniendo ubicación...',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Controles del mapa (lado izquierdo)
          if (isPortrait)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Zoom in
                    FloatingActionButton(
                      onPressed: _zoomIn,
                      mini: true,
                      backgroundColor: Colors.white,
                      elevation: 3,
                      child: const Icon(Icons.add, color: Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    // Zoom out
                    FloatingActionButton(
                      onPressed: _zoomOut,
                      mini: true,
                      backgroundColor: Colors.white,
                      elevation: 3,
                      child: const Icon(Icons.remove, color: Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    // Reset rotation
                    FloatingActionButton(
                      onPressed: _resetRotation,
                      mini: true,
                      backgroundColor: Colors.white,
                      elevation: 3,
                      tooltip: 'Resetear rotación',
                      child: const Icon(
                        Icons.filter_center_focus,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Información de ubicación (abajo)
          if (userLocation != null && !loading)
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 12.0,
                    right: 12.0,
                    bottom: 12.0,
                    top: 8.0,
                  ),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [Colors.blue[400]!, Colors.blue[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ubicación actual',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  'Z: ${currentZoom.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Latitud',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      userLocation.latitude.toStringAsFixed(5),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 35,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Longitud',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      userLocation.longitude.toStringAsFixed(5),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),

      // Botón flotante de localización (esquina inferior derecha)
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnUserLocation,
        tooltip: 'Centrar en mi ubicación',
        backgroundColor: Colors.blue,
        elevation: 5,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
