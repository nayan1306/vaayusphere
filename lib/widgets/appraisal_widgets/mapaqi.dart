import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:vaayusphere/providers/apidataprovider.dart';
import 'package:vaayusphere/widgets/dashboard_widgets/glasscard.dart';

class MapAqi extends StatefulWidget {
  const MapAqi({super.key});

  @override
  _MapAqiState createState() => _MapAqiState();
}

class _MapAqiState extends State<MapAqi> {
  // Initial marker position (center of India)
  LatLng _markerPosition = const LatLng(22.5937, 78.9629);

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiDataProvider>(
      builder: (context, apiDataProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: GlassCard(
            child: SizedBox(
              width: 800,
              height: 580,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _markerPosition,
                    initialZoom: 5.1,
                    minZoom: 2,
                    maxZoom: 16,
                    onTap: (tapPosition, latLng) {
                      setState(() {
                        _markerPosition = latLng;
                      });

                      // Notify provider of new location
                      apiDataProvider.updateLocation(
                          latLng.latitude, latLng.longitude);
                    },
                  ),
                  children: [
                    // Satellite Tile Layer (Base layer)
                    TileLayer(
                      urlTemplate:
                          "https://api.maptiler.com/maps/basic-v2/{z}/{x}/{y}.png?key=Zhdacbt80Hxoxt0lpVVq",
                      userAgentPackageName: 'com.example.app',
                    ),
                    // AQICN Tile Layer (Overlay layer with transparency)
                    TileLayer(
                      urlTemplate:
                          "https://tiles.aqicn.org/tiles/usepa-aqi/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.example.app',
                    ),
                    // Marker Layer
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _markerPosition,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
