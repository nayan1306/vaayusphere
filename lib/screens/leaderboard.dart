import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:vaayusphere/common/locationsearchbar.dart';
import 'package:vaayusphere/widgets/leaderboard_widgets/toppolluters.dart';
import 'package:vaayusphere/widgets/leaderboard_widgets/global_countries_list.dart';

class LeaderboardScreenPlaceholder extends StatefulWidget {
  const LeaderboardScreenPlaceholder({
    super.key,
    required this.controller,
  });

  final SidebarXController controller;

  @override
  State<LeaderboardScreenPlaceholder> createState() =>
      _LeaderboardScreenPlaceholderState();
}

class _LeaderboardScreenPlaceholderState
    extends State<LeaderboardScreenPlaceholder>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _sizedBoxHeight = 50.0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _scrollController.addListener(() {
      setState(() {
        _sizedBoxHeight = _scrollController.offset > 0 ? 0.0 : 50.0;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
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
                    color: const Color.fromARGB(218, 140, 100, 100)
                        .withOpacity(0.5),
                  ),
                  child: Image.network(
                    "https://raw.githubusercontent.com/nayan1306/assets/main/long_pollution.jpg",
                    fit: BoxFit.contain,
                    repeat: ImageRepeat.repeat,
                    errorBuilder: (context, error, stackTrace) {
                      // Display a placeholder if image fails to load
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 50),
                        ),
                      );
                    },
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
                          const SizedBox(width: 20),
                          const Expanded(child: LocationSearchBar()),
                          IconButton(
                            icon: Icon(
                              Icons.notifications,
                              size: 40,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.settings,
                              size: 40,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.account_circle,
                              size: 40,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      SizedBox(height: _sizedBoxHeight),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Air Pollution Leaderboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White title for glassy look
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Global air quality rankings and statistics',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Tab Controller for sections
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Most Polluted Cities'),
                      Tab(text: 'Countries Ranking'),
                    ],
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.lightGreenAccent,
                  ),
                ],
              ),
            ),
          ),
          // This is the key difference - use SliverFillRemaining with a TabBarView
          SliverFillRemaining(
            hasScrollBody: true,
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Wrap in SingleChildScrollView to prevent overflow
                SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: TopPolluters(),
                ),
                // Wrap in SingleChildScrollView to prevent overflow
                SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: GlobalCountriesList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
