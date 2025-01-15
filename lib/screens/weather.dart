import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';
// import 'package:vaayusphere/common/sidebar.dart';
import 'package:vaayusphere/providers/apidataprovider.dart';
import 'package:flutter_location_search/flutter_location_search.dart';
import 'package:vaayusphere/widgets/weather_widgets/precipitationforecast.dart';
import 'package:vaayusphere/widgets/weather_widgets/weathercardbig.dart';

class WeatherScreenPlaceHolder extends StatefulWidget {
  const WeatherScreenPlaceHolder({
    super.key,
    required this.controller,
  });

  final SidebarXController controller;

  @override
  State<WeatherScreenPlaceHolder> createState() => _DashboardPlaceholderState();
}

class _DashboardPlaceholderState extends State<WeatherScreenPlaceHolder> {
  final ScrollController _scrollController = ScrollController();
  double _sizedBoxHeight = 50.0;
  String _selectedLocation =
      'Tap here to search a place'; // Default text for location

  @override
  void initState() {
    super.initState();

    // Fetch air quality data when the widget is initialized
    Future.delayed(Duration.zero, () {
      final provider = Provider.of<ApiDataProvider>(context, listen: false);
      // provider.fetchAndSetWeatherForecastData();
      provider.fetchAndSetWeatherForecastDataDetailed();
    });

    _scrollController.addListener(() {
      setState(() {
        _sizedBoxHeight = _scrollController.offset > 0 ? 0.0 : 50.0;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation() async {
    LocationData? locationData = await LocationSearch.show(
      countryCodes: ['IN'],
      context: context,
      lightAddress: false,
      mode: Mode.overlay,
    );

    if (locationData != null) {
      setState(() {
        _selectedLocation = locationData.address;
      });
      // You can handle the location data further, e.g., fetch weather data for the selected location.
      print('Selected location: ${locationData.address}');
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0, // Height of the flexible space
            pinned: true,
            backgroundColor: const Color.fromARGB(0, 32, 31, 51),
            flexibleSpace: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: FlexibleSpaceBar(
                background: Container(
                  foregroundDecoration: BoxDecoration(
                    color:
                        const Color.fromARGB(184, 51, 32, 64).withOpacity(0.5),
                  ),
                  child: Image.network(
                    "https://raw.githubusercontent.com/nayan1306/assets/refs/heads/main/mount_long.png",
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          // Use TextButton for location search
                          TextButton(
                            onPressed: _searchLocation,
                            child: Text(
                              _selectedLocation,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.notifications,
                              size: 40,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.settings,
                              size: 40,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.account_circle,
                              size: 40,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      SizedBox(
                        height: _sizedBoxHeight,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListView.builder(
              shrinkWrap:
                  true, // Allows the ListView to be used inside a CustomScrollView
              physics: const ScrollPhysics(),
              itemCount:
                  1, // You can adjust this based on how many sections you need
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WeatherCardBig(),
                      SizedBox(
                        height: 20,
                      ),
                      PrecipitationForecastLineChart()
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
