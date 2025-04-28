import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:vaayusphere/common/sidebar.dart';
import 'package:vaayusphere/routes/screens_navigation.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YΛΛYU sphere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        canvasColor: canvasColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      // routes: appRoutes, // Add this line to include navigation routes
      home: Builder(
        builder: (context) {
          final isSmallScreen = MediaQuery.of(context).size.width < 600;
          return Scaffold(
            key: _key,
            appBar: isSmallScreen
                ? AppBar(
                    backgroundColor: canvasColor,
                    title: const Text("Sample Screen"),
                    leading: IconButton(
                      onPressed: () {
                        // if (!Platform.isAndroid && !Platform.isIOS) {
                        //   _controller.setExtended(true);
                        // }
                        _key.currentState?.openDrawer();
                      },
                      icon: const Icon(Icons.menu),
                    ),
                  )
                : null,
            drawer: ExampleSidebarX(controller: _controller),
            body: Row(
              children: [
                if (!isSmallScreen) ExampleSidebarX(controller: _controller),
                Expanded(
                  child: ScreensExample(
                    controller: _controller,
                  ),
                  //   child: Center(
                  //       child: DashboardPlaceholder(controller: _controller)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
