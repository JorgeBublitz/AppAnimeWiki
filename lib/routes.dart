/// Nomes centralizados de todas as rotas (telas) do app.
///
/// Hoje a navegação é toda manual, espalhada pelo código:
///   Navigator.push(context, MaterialPageRoute(builder: (_) => AlgumaTela(...)));
/// cada tela importando a próxima direto. Esse arquivo é o primeiro passo
/// pra centralizar isso: só os NOMES das rotas, um por tela do app.
///
/// Só [profile] e [animeDetail] estão de fato ligados (ver `onGenerateRoute`
/// em main.dart) — são os 2 exemplos completos, incluindo troca de uma
/// chamada real em home_screen.dart. Os demais nomes já estão prontos pra
/// usar; falta, pra cada um:
///   1. Adicionar o `case` correspondente em `onGenerateRoute` (main.dart)
///   2. Trocar os `Navigator.push(MaterialPageRoute(...))` que apontam pra
///      essa tela por `Navigator.pushNamed(context, AppRoutes.x, arguments: ...)`
class AppRoutes {
  AppRoutes._();

  // Já ligadas (exemplo)
  static const profile = '/profile';
  static const animeDetail = '/anime-detail';

  // Ainda não ligadas — só os nomes
  static const home = '/home';
  static const login = '/login';
  static const signup = '/signup';
  static const mangaDetail = '/manga-detail';
  static const allAnime = '/anime';
  static const allManga = '/manga';
  static const allCharactersAnime = '/anime-characters';
  static const allCharactersManga = '/manga-characters';
  static const animePersonDetail = '/anime-person-detail';
  static const mangaPersonDetail = '/manga-person-detail';
}
