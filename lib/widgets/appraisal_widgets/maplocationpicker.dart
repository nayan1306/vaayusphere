import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class MapLocationPicker extends StatelessWidget {
  const MapLocationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1500,
      height: 700,
      child: FlutterLocationPicker(
        initPosition: const LatLong(22.5937, 78.9629), // Center of India
        selectLocationButtonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.blue),
        ),
        selectLocationButtonText: 'Set Current Location',
        initZoom: 5.5, // Zoom level to fit the whole country
        minZoomLevel: 3,
        maxZoomLevel: 16,
        trackMyPosition: true,
        onError: (e) {
          print('Error occurred: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        },
        onPicked: (pickedData) {
          print('Latitude: ${pickedData.latLong.latitude}');
          print('Longitude: ${pickedData.latLong.longitude}');
          print('Address: ${pickedData.address}');
        },
      ),
    );
  }
}