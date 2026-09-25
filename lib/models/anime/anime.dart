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

  // Mapeia a resposta da AniList (GraphQL) para o mesmo modelo usado pela
  // Jikan, assim o resto do app (telas, cards) continua funcionando sem
  // alteração enquanto a migração dos outros métodos não termina.
  //
  // Isto é um EXEMPLO de migração (ver ApiService.topAnimesAniList) — os
  // outros pontos que usam Anime.fromJson (Jikan) ainda precisam ser
  // convertidos à mão seguindo o mesmo padrão.
  factory Anime.fromAniListJson(Map<String, dynamic> json, {int rank = 0}) {
    final title = json['title'] as Map<String, dynamic>? ?? {};
    final coverUrl = (json['coverImage']?['large'] as String?) ?? '';
    final malId = json['idMal'] as int?;

    return Anime(
      // idMal existe pra maioria dos títulos populares (a AniList mapeia pro
      // MyAnimeList). Sem ele, as telas que ainda chamam a Jikan usando esse
      // id (personagens, por exemplo) não funcionam pra esse item até essa
      // parte também ser migrada.
      malId: malId,
      url: malId != null ? 'https://myanimelist.net/anime/$malId' : '',
      images: Images.fromJson({
        'jpg': {'image_url': coverUrl, 'large_image_url': coverUrl},
      }),
      title:
          (title['romaji'] as String?) ?? (title['english'] as String?) ?? '',
      genres:
          (json['genres'] as List? ?? [])
              .map((name) => GenreAnime(malId: 0, name: name as String))
              .toList(),
      titleEnglish: title['english'] as String?,
      titleJapanese: title['native'] as String?,
      titleSynonyms: const [],
      type: (json['format'] as String? ?? '').toLowerCase(),
      source: (json['source'] as String? ?? '').toLowerCase(),
      episodes: json['episodes'] as int?,
      status: _statusFromAniList(json['status'] as String?),
      airing: json['status'] == 'RELEASING',
      // AniList usa nota de 0 a 100; o resto do app espera 0 a 10 (padrão Jikan).
      score: ((json['averageScore'] as num? ?? 0) / 10).toDouble(),
      rating: '',
      rank: rank,
      // Atenção: na Jikan "popularity" é um RANK (menor = mais popular). A
      // AniList não tem esse conceito nessa query — aqui é só a posição na
      // lista (já ordenada por nota), então NÃO é comparável com o campo
      // popularity vindo da Jikan nos métodos que ainda não foram migrados.
      popularity: rank,
      favorites: json['favourites'] as int? ?? 0,
      synopsis: _stripHtml(json['description'] as String?),
      background: null,
      season: (json['season'] as String?)?.toLowerCase(),
      year: json['seasonYear'] as int?,
    );
  }

  static String _statusFromAniList(String? status) {
    switch (status) {
      case 'RELEASING':
        return 'Currently Airing';
      case 'FINISHED':
        return 'Finished Airing';
      case 'NOT_YET_RELEASED':
        return 'Not yet aired';
      default:
        return status ?? '';
    }
  }

  static String? _stripHtml(String? html) {
    if (html == null) return null;
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '');
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
