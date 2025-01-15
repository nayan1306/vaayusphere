import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart'; // Import flutter_map
import 'package:latlong2/latlong.dart'; // Import latlong2 for handling LatLng
import 'package:vaayusphere/widgets/dashboard_widgets/glasscard.dart';
import 'package:vaayusphere/providers/apidataprovider.dart'; // Adjust import path

class StaticAqiMapIndia extends StatelessWidget {
  const StaticAqiMapIndia({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the air quality data from the provider
    final airQualityData =
        Provider.of<ApiDataProvider>(context).airQualityData?.values.toList() ??
            [];

    // Example coordinates for India (Central location)
    const LatLng initialPosition =
        LatLng(20.5937, 78.9629); // Central coordinates of India

    return SizedBox(
      width: 830,
      height: 610,
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(15.0), // Rounded corners for the map
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.yellow,
                  ),
                  child: FlutterMap(
                    options: const MapOptions(
                      initialCenter: initialPosition,
                      initialZoom: 4.5, // Initial zoom level
                      // backgroundColor: Colors.black,
                      keepAlive: true,
                      // maxZoom:
                      //     4.0, // Adjust the zoom level to show the entire country
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', // OpenStreetMap URL
                        subdomains: const [
                          'a',
                          'b',
                          'c'
                        ], // Multiple subdomains for faster tile loading
                      ),
                      MarkerLayer(
                        markers: _createMarkers(
                            airQualityData), // Add markers based on the AQI data
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Marker> _createMarkers(List<dynamic> airQualityData) {
    List<Marker> markers = [];

    // Example: Adding markers for each air quality data point (this is based on your data structure)
    // ignore: unused_local_variable
    for (var data in airQualityData) {
      // Replace with actual latitude and longitude from airQualityData
      double lat = 21.5166; // Example latitude
      double lng = 81.8380; // Example longitude

      markers.add(
        Marker(
          point: LatLng(lat, lng),
          child: const Icon(
            Icons.location_on,
            color: Colors.red, // Customize the marker icon color
            size: 30.0, // Customize the marker icon size
          ),
        ),
      );
    }

    return markers;
  }
}
