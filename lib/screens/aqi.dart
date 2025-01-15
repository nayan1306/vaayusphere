import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:vaayusphere/common/sidebar.dart';
import 'package:vaayusphere/providers/apidataprovider.dart';

class AqiScreenPlaceholder extends StatefulWidget {
  const AqiScreenPlaceholder({
    super.key,
    required this.controller,
  });

  final SidebarXController controller;

  @override
  State<AqiScreenPlaceholder> createState() => _AqiScreenPlaceholderState();
}

class _AqiScreenPlaceholderState extends State<AqiScreenPlaceholder> {
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
            backgroundColor: const Color.fromARGB(0, 32, 31, 51),
            flexibleSpace: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
              child: FlexibleSpaceBar(
                background: Container(
                  foregroundDecoration: BoxDecoration(
                    color:
                        const Color.fromARGB(104, 53, 69, 70).withOpacity(0.5),
                  ),
                  child: Image.network(
                    "https://raw.githubusercontent.com/nayan1306/assets/refs/heads/main/clouds.jpg",
                    fit: BoxFit.contain,
                    repeat: ImageRepeat.repeat,
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
                    children: [],
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
