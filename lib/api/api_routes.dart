/// Nomes centralizados de todos os endpoints usados pelo app — tanto os que
/// ainda são da Jikan (REST, em descontinuação — ver README) quanto os que
/// já migraram pra AniList (GraphQL).
///
/// Cada função em api_service.dart deve referenciar uma constante daqui em
/// vez de escrever o caminho na mão.
///
/// Só [JikanRoutes.topAnime] e [AniListRoutes.topAnime] estão de fato em uso
/// (ver ApiService.topAnimes / topAnimesAniList) — são os 2 exemplos
/// completos. O resto são os nomes já prontos pra usar quando você criar a
/// função correspondente em api_service.dart.
class JikanRoutes {
  JikanRoutes._();

  static const baseUrl = 'https://api.jikan.moe/v4';

  // Em uso (exemplo)
  static const topAnime = 'top/anime';

  // Ainda não centralizados — os métodos que os usam hoje montam o caminho
  // direto na chamada; migre pra cá conforme for mexendo em cada um.
  static const topManga = 'top/manga';
  static const animeList = 'anime';
  static const mangaList = 'manga';
  static const animeFull = 'anime/{id}/full';
  static const mangaFull = 'manga/{id}/full';
  static const animeCharacters = 'anime/{id}/characters';
  static const mangaCharacters = 'manga/{id}/characters';
  static const characterDetail = 'characters/{id}';
  static const characterFull = 'characters/{id}/full';
  static const characterVoices = 'characters/{id}/voices';
}

class AniListRoutes {
  AniListRoutes._();

  static const baseUrl = 'https://graphql.anilist.co';

  // A AniList tem um único endpoint (GraphQL) — os nomes abaixo identificam
  // a query/operação, não um caminho de URL como na Jikan.

  // Em uso (exemplo)
  static const topAnime = 'topAnime';

  // Ainda não implementadas
  static const topManga = 'topManga';
  static const animeList = 'animeList';
  static const mangaList = 'mangaList';
  static const animeDetail = 'animeDetail';
  static const mangaDetail = 'mangaDetail';
  static const characterDetail = 'characterDetail';
}
