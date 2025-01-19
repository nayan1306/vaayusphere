import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:vaayusphere/providers/apidataprovider.dart';

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
        return SizedBox(
          width: 1200,
          height: 800,
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
              // // Satellite Tile Layer
              // TileLayer(
              //   urlTemplate:
              //       "https://api.maptiler.com/maps/satellite/256/{z}/{x}/{y}.jpg?key=Zhdacbt80Hxoxt0lpVVq",
              //   userAgentPackageName: 'com.example.app',
              // ),
              // AQICN Tile Layer
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
                    child: const Text("temp"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
