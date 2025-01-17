import 'package:flutter/material.dart';
import 'package:animated_cards_carousel/animated_cards_carousel.dart';
import 'package:vaayusphere/widgets/news_widgets/newsglasscard.dart';

class NewsList extends StatelessWidget {
  const NewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.8,
      child: AnimatedCardsCarousel(
        cardAspectRatio: 6,
        cardsList: List.generate(
            100,
            (index) => const NewsGlassCard(
                  headline: 'Breaking News: Flutter Rocks!',
                  description:
                      'Flutter continues to revolutionize the mobile development world with its rich set of features and cross-platform capabilities,Flutter continues to revolutionize the mobile development world with its rich set of features and cross-platform capabilities,Flutter continues to revolutionize the mobile development world with its rich set of features and cross-platform capabilities',
                  imageUrl:
                      'https://raw.githubusercontent.com/nayan1306/assets/refs/heads/main/city.jpg', // Dummy image URL
                )),
      ),
    );
  }
}
