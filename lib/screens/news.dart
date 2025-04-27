import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:vaayusphere/api/news_api_service.dart';
import 'package:vaayusphere/common/locationsearchbar.dart';
import 'package:vaayusphere/widgets/news_widgets/infocuscard.dart';
import 'package:vaayusphere/widgets/news_widgets/newslist.dart';

class NewsScreenPlaceholder extends StatefulWidget {
  const NewsScreenPlaceholder({
    super.key,
    required this.controller,
  });

  final SidebarXController controller;

  @override
  State<NewsScreenPlaceholder> createState() => _NewsScreenPlaceholderState();
}

class _NewsScreenPlaceholderState extends State<NewsScreenPlaceholder> {
  final ScrollController _scrollController = ScrollController();
  double _sizedBoxHeight = 50.0;

  final PollutionNewsService _newsService = PollutionNewsService();
  late Future<List<Article>> _newsFuture;
  List<Article> _articles = [];
  String _selectedCategory = 'air';
  String _selectedCountry = 'global';
  bool _isLoading = true;

  final Map<String, String> _countries = {
    'global': 'Global',
    'us': 'United States',
    'in': 'India',
    'gb': 'United Kingdom',
    'au': 'Australia',
    'ca': 'Canada',
    'cn': 'China',
    'jp': 'Japan',
    'de': 'Germany',
    'fr': 'France',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _sizedBoxHeight = _scrollController.offset > 0 ? 0.0 : 50.0;
      });
    });
    _fetchNews();
  }

  void _fetchNews() {
    setState(() {
      _isLoading = true;
    });

    final String? country =
        _selectedCountry == 'global' ? null : _selectedCountry;
    _newsFuture = _newsService.getPollutionNews(
      category: _selectedCategory,
      country: country,
    );

    _newsFuture.then((articles) {
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching news: \$error');
    });
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _fetchNews();
  }

  void _onCountryChanged(String country) {
    setState(() {
      _selectedCountry = country;
    });
    _fetchNews();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
                    color: const Color.fromARGB(151, 72, 113, 119)
                        .withOpacity(0.5),
                  ),
                  child: Image.network(
                    "https://raw.githubusercontent.com/nayan1306/assets/refs/heads/main/gcity.jpg",
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
                          const SizedBox(width: 20),
                          const Expanded(child: LocationSearchBar()),
                          IconButton(
                            icon: Icon(Icons.notifications,
                                size: 40, color: Colors.white.withOpacity(0.5)),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.settings,
                                size: 40, color: Colors.white.withOpacity(0.5)),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.account_circle,
                                size: 40, color: Colors.white.withOpacity(0.5)),
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
            child: CountrySelector(
              selectedCountry: _selectedCountry,
              countries: _countries,
              onCountryChanged: _onCountryChanged,
            ),
          ),
          SliverToBoxAdapter(
            child: PollutionNewsCategories(
              selectedCategory: _selectedCategory,
              onCategoryChanged: _onCategoryChanged,
            ),
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _articles.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No articles found for this category and region.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isWide = constraints.maxWidth > 600;
                                    return isWide
                                        ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  child: NewsList(
                                                      articles: _articles)),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.01),
                                              Expanded(
                                                child: InfoFocusCard(
                                                  featuredArticle:
                                                      _articles.isNotEmpty
                                                          ? _articles[0]
                                                          : null,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              NewsList(articles: _articles),
                                              const SizedBox(height: 16),
                                              InfoFocusCard(
                                                featuredArticle:
                                                    _articles.isNotEmpty
                                                        ? _articles[0]
                                                        : null,
                                              ),
                                            ],
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

class CountrySelector extends StatelessWidget {
  final String selectedCountry;
  final Map<String, String> countries;
  final Function(String) onCountryChanged;

  const CountrySelector({
    super.key,
    required this.selectedCountry,
    required this.countries,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(top: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: countries.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                entry.value,
                style: TextStyle(
                  color: selectedCountry == entry.key
                      ? Colors.white
                      : Colors.white54,
                ),
              ),
              selected: selectedCountry == entry.key,
              selectedColor: Theme.of(context).colorScheme.secondary,
              onSelected: (selected) {
                if (selected) {
                  onCountryChanged(entry.key);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class PollutionNewsCategories extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const PollutionNewsCategories({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      'air',
      'water',
      'soil',
      'noise',
      'plastic',
      'industrial',
      'radiation'
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                categories[index].capitalizeFirst(),
                style: TextStyle(
                  color: selectedCategory == categories[index]
                      ? Colors.white
                      : Colors.white54,
                ),
              ),
              selected: selectedCategory == categories[index],
              selectedColor: Theme.of(context).colorScheme.primary,
              onSelected: (selected) {
                if (selected) {
                  onCategoryChanged(categories[index]);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

extension StringExtension on String {
  String capitalizeFirst() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}
