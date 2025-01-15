import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:vaayusphere/common/sidebar.dart';
import 'package:vaayusphere/providers/apidataprovider.dart';
import 'package:vaayusphere/widgets/dashboard_widgets/aqigaugecard.dart';
import 'package:vaayusphere/widgets/dashboard_widgets/aqilinechart.dart';
import 'package:vaayusphere/widgets/dashboard_widgets/aqimapindia.dart';
import 'package:vaayusphere/widgets/dashboard_widgets/infotile.dart';
import 'package:vaayusphere/widgets/dashboard_widgets/no2linechart.dart';
import 'package:vaayusphere/widgets/dashboard_widgets/so2linechart.dart';
import 'package:vaayusphere/widgets/dashboard_widgets/weathercard.dart';

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
  final ScrollController _scrollController = ScrollController();
  double _sizedBoxHeight = 50.0;

  @override
  void initState() {
    super.initState();

    // Fetch air quality data when the widget is initialized
    Future.delayed(Duration.zero, () {
      // ignore: use_build_context_synchronously
      final provider = Provider.of<ApiDataProvider>(context, listen: false);
      provider.fetchAndSetAirQualityData();
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
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                foregroundDecoration: BoxDecoration(
                  color: const Color.fromARGB(184, 51, 32, 64).withOpacity(0.5),
                ),
                child: Image.network(
                  "https://raw.githubusercontent.com/nayan1306/assets/refs/heads/main/pmountbanner.png",
                  fit: BoxFit.cover,
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
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search Location',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(61, 255, 255, 255),
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
                      )
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
