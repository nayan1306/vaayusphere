import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:vaayusphere/common/sidebar.dart';
import 'package:vaayusphere/providers/apidataprovider.dart';
import 'package:vaayusphere/widgets/aqigaugecard.dart';
import 'package:vaayusphere/widgets/aqilinechart.dart';
import 'package:vaayusphere/widgets/aqimapindia.dart';
import 'package:vaayusphere/widgets/infotile.dart';
import 'package:vaayusphere/widgets/no2linechart.dart';
import 'package:vaayusphere/widgets/so2linechart.dart';
import 'package:vaayusphere/widgets/weathercard.dart';

class DashboardPlaceholder extends StatefulWidget {
  const DashboardPlaceholder({
    super.key,
    required this.controller,
  });

  final SidebarXController controller;

  @override
  State<DashboardPlaceholder> createState() => _DashboardPlaceholderState();
}

class _DashboardPlaceholderState extends State<DashboardPlaceholder> {
  @override
  void initState() {
    super.initState();

    // Fetch air quality data when the widget is initialized
    Future.delayed(Duration.zero, () {
      // ignore: use_build_context_synchronously
      final provider = Provider.of<ApiDataProvider>(context, listen: false);
      provider.fetchAndSetAirQualityData();
    });
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0, // Height of the flexible space
            pinned: true,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color:
                    canvasColor, // Set the background color or image as needed
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
                      Row(
                        children: [
                          AqiPm10InfoTile(),
                          SizedBox(width: 20),
                          AqiPm2InfoTile(),
                          SizedBox(width: 20),
                          SulphurDioxideInfoTile(),
                          SizedBox(width: 20),
                          NitrogenDioxideInfoTile(),
                          SizedBox(width: 30),
                          AqiGaugeCard(),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          AqiLineChart(),
                          SizedBox(width: 20),
                          WeatherCard(),
                        ],
                      ),
                      // SizedBox(height: 20), // Add spacing between rows
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 20),
                              No2LineChart(),
                              SizedBox(height: 20),
                              So2LineChart()
                            ],
                          ),
                          SizedBox(width: 20),
                          StaticAqiMapIndia()
                        ],
                      ),
                      Row(
                        children: [],
                      ),
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
