import 'package:flutter/material.dart';
import 'package:vaayusphere/widgets/coolsearchfield.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double height;

  const CommonAppBar({
    super.key,
    required this.title,
    this.height = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Padding from all sides
        child: Container(
          decoration: BoxDecoration(
            color: theme.canvasColor,
            borderRadius: BorderRadius.circular(15), // Slightly rounded corners
            border: Border.all(
              color: const Color.fromARGB(255, 46, 46, 46),
              width: 1.0,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0, // Remove shadow to match custom border styling
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            title: Row(
              children: [
                // Stretch the search bar completely to the left
                Expanded(
                  child: CoolSearchField(
                    hintText: "Search...",
                    onChanged: (query) {
                      print("Search query: $query");
                    },
                  ),
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                ),
                // Icons aligned to the right
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.grey),
                      onPressed: () {
                        print("Notifications clicked");
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.grey),
                      onPressed: () {
                        print("Favorites clicked");
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.grey),
                      onPressed: () {
                        print("Settings clicked");
                      },
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.person_2_rounded,
                          color: Colors.grey,
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
