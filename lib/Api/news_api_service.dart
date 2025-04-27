import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

/// Combined service and data models for pollution news.
class PollutionNewsService {
  static const _baseHost = 'newsapi.org';
  static const _basePath = '/v2/everything';
  static const _apiKey = 'e3512586c27b41f3bc34ce245f2a7293';

  /// Fallback query for general pollution news.
  static const _baseQuery =
      'pollution OR contamination OR environmental damage OR environmental impact';

  /// Default image URL if the article has none.
  static const defaultImageUrl =
      'https://via.placeholder.com/400x200?text=Pollution+News';

  /// Specific queries for pollution categories.
  static const Map<String, String> categoryQueries = {
    'air': 'air pollution',
    'water':
        'water pollution OR water contamination OR clean water OR ocean pollution',
    'soil':
        'soil pollution OR land contamination OR soil quality OR pesticides',
    'noise': 'noise pollution OR sound pollution OR urban noise OR quiet zones',
    'plastic':
        'plastic pollution OR plastic waste OR microplastics OR plastic recycling',
    'industrial':
        'industrial pollution OR factory emissions OR industrial waste OR chemical spills',
    'radiation':
        'radiation pollution OR nuclear waste OR radioactive contamination'
  };

  /// Fetches pollution news.
  /// Optionally scoped by `country` (ISO code) and `category`.
  Future<List<Article>> getPollutionNews({
    String? country,
    String? category,
    int pageSize = 20,
  }) async {
    final query = _buildQuery(country: country, category: category);
    return _searchNews(query, pageSize: pageSize);
  }

  String _buildQuery({String? country, String? category}) {
    final base = category != null && categoryQueries.containsKey(category)
        ? categoryQueries[category]!
        : _baseQuery;
    if (country != null && country.isNotEmpty) {
      return '$base AND ${_countryName(country)}';
    }
    return base;
  }

  Future<List<Article>> _searchNews(
    String query, {
    int pageSize = 20,
    String language = 'en',
    String sortBy = 'publishedAt',
  }) async {
    try {
      log('Searching news: $query');
      final uri = Uri.https(_baseHost, _basePath, {
        'q': query,
        'pageSize': '$pageSize',
        'language': language,
        'sortBy': sortBy,
        'apiKey': _apiKey,
      });
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        log('NewsAPI error ${res.statusCode}: ${res.body}');
        return [];
      }
      final body = json.decode(res.body) as Map<String, dynamic>;
      final list = (body['articles'] as List<dynamic>? ?? []);
      return list.map((j) => _processArticle(j)).toList();
    } catch (e, st) {
      log('Error fetching news: $e', stackTrace: st);
      return [];
    }
  }

  Article _processArticle(Map<String, dynamic> json) {
    var art = Article.fromJson(json);
    final raw = art.urlToImage;
    final img = (raw != null && raw.isNotEmpty)
        ? raw.replaceFirst(RegExp(r'^http:'), 'https:')
        : defaultImageUrl;
    return art.copyWith(urlToImage: img);
  }

  String _countryName(String code) {
    const map = {
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
    return map[code.toLowerCase()] ?? code;
  }
}

/// Represents a news article.
class Article {
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final String publishedAt;
  final String content;
  final Source source;

  Article({
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    required this.content,
    required this.source,
  });

  Article copyWith({String? urlToImage}) {
    return Article(
      title: title,
      description: description,
      url: url,
      urlToImage: urlToImage ?? this.urlToImage,
      publishedAt: publishedAt,
      content: content,
      source: source,
    );
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] as String? ?? 'No title',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? '',
      urlToImage: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] as String? ?? '',
      content: json['content'] as String? ?? '',
      source: Source.fromJson((json['source'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

/// The source (e.g. 'BBC') of an article.
class Source {
  final String? id;
  final String name;
  Source({this.id, required this.name});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Unknown Source',
    );
  }
}
