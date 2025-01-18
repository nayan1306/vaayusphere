import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:vaayusphere/common/locationsearchbar.dart';
import 'package:vaayusphere/widgets/appraisal_widgets/maplocationpicker.dart';

class AppraisalScreenPlaceholder extends StatefulWidget {
  const AppraisalScreenPlaceholder({
    super.key,
    required this.controller,
  });

  final SidebarXController controller;

  @override
  State<AppraisalScreenPlaceholder> createState() =>
      _AppraisalScreenPlaceholderState();
}

class _AppraisalScreenPlaceholderState
    extends State<AppraisalScreenPlaceholder> {
  final ScrollController _scrollController = ScrollController();
  double _sizedBoxHeight = 50.0;

  @override
  void initState() {
    super.initState();

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
                    color: const Color.fromARGB(150, 114, 177, 124)
                        .withOpacity(0.5),
                  ),
                  child: Image.network(
                    "https://img.goodfon.com/original/1920x1080/0/64/listia-fon-background-leaves-still-life-kompozitsiia-dark-ba.jpg",
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
                          const Expanded(
                            child: LocationSearchBar(),
                          ),
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
              itemCount: 1, // Adjust this based on sections needed
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // final isWide = constraints.maxWidth > 600;

                          // Use Row for wide layouts and Column for narrow layouts
                          return const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [MapLocationPicker()],
                          );
                        },
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
