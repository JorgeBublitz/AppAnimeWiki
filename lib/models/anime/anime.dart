import '../image.dart';
import 'package:app/models/anime/genre_anime.dart';

class Anime {
  final int? malId;
  final String url;
  final Images images;
  final String title;
  final List<GenreAnime> genres;
  final String? titleEnglish;
  final String? titleJapanese;
  final List<String> titleSynonyms;
  final String type;
  final String source;
  final int? episodes;
  final String status;
  final bool airing;
  final double score;
  final String rating;
  final int rank;
  final int popularity;
  final int favorites;
  final String? synopsis;
  final String? background;
  final String? season;
  final int? year;

  Anime({
    required this.malId,
    required this.url,
    required this.images, //uso
    required this.title, //uso
    required this.genres,
    this.titleEnglish, //uso
    this.titleJapanese, //uso
    required this.titleSynonyms, //uso
    required this.type, //uso
    required this.source, //uso
    this.episodes, //uso
    required this.status,
    required this.airing,
    required this.score,
    required this.rating,
    required this.rank,
    required this.popularity,
    required this.favorites,
    this.synopsis,
    this.background,
    this.season,
    this.year,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      malId: json['mal_id'] ?? 0,
      url: json['url'] ?? '',
      images: Images.fromJson(json['images'] ?? {}),
      title: json['title'] ?? '',
      genres:
          (json['genres'] as List? ?? [])
              .map((g) => GenreAnime.fromJson(g))
              .toList(),
      titleEnglish: json['title_english'],
      titleJapanese: json['title_japanese'],
      titleSynonyms: List<String>.from(json['title_synonyms'] ?? []),
      type: json['type'] ?? '',
      source: json['source'] ?? '',
      episodes: json['episodes'],
      status: json['status'] ?? '',
      airing: json['airing'] ?? false,
      score: (json['score'] as num? ?? 0).toDouble(),
      rating: json['rating'] ?? '',
      rank: json['rank'] ?? 0,
      popularity: json['popularity'] ?? 0,
      favorites: json['favorites'] ?? 0,
      synopsis: json['synopsis'],
      background: json['background'],
      season: json['season'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mal_id': malId,
      'url': url,
      'images': images.toJson(),
      'title': title,
      if (titleEnglish != null) 'title_english': titleEnglish,
      if (titleJapanese != null) 'title_japanese': titleJapanese,
      'title_synonyms': titleSynonyms,
      'type': type,
      'source': source,
      if (episodes != null) 'episodes': episodes,
      'status': status,
      'airing': airing,
      'score': score,
      'rating': rating,
      'rank': rank,
      'popularity': popularity,
      'favorites': favorites,
      if (synopsis != null) 'synopsis': synopsis,
      if (background != null) 'background': background,
      if (season != null) 'season': season,
      if (year != null) 'year': year,
    };
  }
}
