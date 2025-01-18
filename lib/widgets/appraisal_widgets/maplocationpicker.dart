import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:vaayusphere/providers/apidataprovider.dart';

class MapLocationPicker extends StatefulWidget {
  const MapLocationPicker({super.key});

  @override
  _MapLocationPickerState createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  // Initial marker position (fixed at the center of India)

  LatLong _markerPosition = const LatLong(22.5937, 78.9629);

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiDataProvider>(
      builder: (context, apiDataProvider, child) {
        return SizedBox(
          width: 1200,
          height: 800,
          child: FlutterLocationPicker(
            initPosition:
                _markerPosition, // Start with the fixed initial position
            initZoom: 5.1, // Set zoom to show India
            minZoomLevel: 2,
            maxZoomLevel: 16,
            mapLanguage: 'en',
            selectLocationButtonText: 'Set Location',
            searchBarBackgroundColor: const Color.fromARGB(141, 209, 240, 255),
            selectLocationButtonStyle: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                const Color.fromARGB(141, 209, 240, 255),
              ),
            ),
            selectedLocationButtonTextStyle: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
            selectLocationButtonWidth: 200,

            urlTemplate:
                "https://api.maptiler.com/maps/satellite/256/{z}/{x}/{y}.jpg?key=Zhdacbt80Hxoxt0lpVVq",
            markerIcon: const Icon(
              Icons.location_on,
              size: 40,
              color: Colors.red,
            ),
            zoomButtonsColor: Colors.black,
            zoomButtonsBackgroundColor:
                const Color.fromARGB(141, 209, 240, 255),
            locationButtonsColor: Colors.black,
            locationButtonBackgroundColor:
                const Color.fromARGB(141, 209, 240, 255),
            showCurrentLocationPointer: true, // Marker is always fixed
            trackMyPosition:
                false, // Disable auto-tracking to keep the marker fixed
            showSearchBar: true, // Enable search functionality
            onPicked: (pickedData) {
              setState(() {
                // Update the marker position when a location is selected
                _markerPosition = pickedData.latLong;
              });

              // Notify the provider with the updated location
              apiDataProvider.updateLocation(
                pickedData.latLong.latitude,
                pickedData.latLong.longitude,
              );

              apiDataProvider.updateSelectedLocation(
                  pickedData.latLong.latitude,
                  pickedData.latLong.longitude,
                  pickedData.address);
            },
            onError: (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            },
          ),
        );
      },
    );
  }
}
