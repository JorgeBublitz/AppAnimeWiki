import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime/anime.dart';
import '../models/manga/manga.dart';
import '../models/anime/anime_person.dart';
import '../models/manga/manga_person.dart';
import '../models/dublagem/voice.dart';
import '../models/character.dart';

class ApiService {
  static const _baseUrl = "https://api.jikan.moe/v4";

  // A Jikan é uma API não-oficial (scraping do MyAnimeList) e, por
  // documentação própria, pode devolver 429 (rate limit) ou 5xx quando o
  // MyAnimeList está instável ("It's still possible to get rate limited
  // from MyAnimeList.net instead"). Esses erros costumam ser transitórios,
  // então tentamos de novo algumas vezes com backoff antes de desistir.
  static Future<http.Response> _getWithRetry(
    Uri url, {
    int maxRetries = 2,
  }) async {
    var attempt = 0;
    while (true) {
      final response = await http.get(url);
      final isRetryable =
          response.statusCode == 429 ||
          (response.statusCode >= 500 && response.statusCode < 600);
      if (!isRetryable || attempt >= maxRetries) {
        return response;
      }
      attempt++;
      await Future.delayed(Duration(milliseconds: 500 * attempt));
    }
  }

  // Método genérico para buscar dados
  static Future<List<Map<String, dynamic>>> _getListData(
    String endpoint,
  ) async {
    try {
      final response = await _getWithRetry(Uri.parse("$_baseUrl/$endpoint"));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['data']);
      }
      throw Exception("Erro ${response.statusCode}: ${response.reasonPhrase}");
    } catch (e) {
      throw Exception("Erro de conexão: $e");
    }
  }

  // Método genérico para buscar um único item
  static Future<Map<String, dynamic>> _getSingleData(String endpoint) async {
    try {
      final response = await _getWithRetry(Uri.parse("$_baseUrl/$endpoint"));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data'];
      }
      throw Exception("Erro ${response.statusCode}: ${response.reasonPhrase}");
    } catch (e) {
      throw Exception("Erro de conexão: $e");
    }
  }

  // Métodos para Top Animes
  static Future<List<Anime>> topAnimes({int limit = 10}) async {
    final data = await _getListData("top/anime?limit=$limit");
    return data.map((json) => Anime.fromJson(json)).toList();
  }

  static Future<Map<String, dynamic>> fetchAnimes({
    required int page,
    int limit = 24,
    String query = '',
    bool sfw = true,
  }) async {
    // Corrigindo a URL para incluir o endpoint /anime
    final url = Uri.parse(
      '$_baseUrl/anime?page=$page&limit=$limit&q=${Uri.encodeQueryComponent(query)}&sfw=$sfw',
    );

    final response = await _getWithRetry(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final pagination = data['pagination'];
      final items = data['data'] as List;
      final animes = items.map((e) => Anime.fromJson(e)).toList();

      return {
        'animes': animes,
        'totalPages': pagination['last_visible_page'] ?? 1,
      };
    } else {
      throw Exception('Erro na requisição: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> fetchMangas({
    required int page,
    int limit = 24,
    String query = '',
    bool sfw = true,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/manga?page=$page&limit=$limit&q=${Uri.encodeQueryComponent(query)}&sfw=$sfw',
    );

    final response = await _getWithRetry(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final pagination = data['pagination'];
      final items = data['data'] as List;

      // Corrigido para Manga
      final mangas = items.map((e) => Manga.fromJson(e)).toList();

      return {
        'mangas': mangas, // Chave corrigida
        'totalPages': pagination['last_visible_page'] ?? 1,
      };
    } else {
      throw Exception('Erro na requisição: ${response.statusCode}');
    }
  }

  // Métodos para Top Mangás
  static Future<List<Manga>> topMangas({int limit = 10}) async {
    final data = await _getListData("top/manga?limit=$limit");
    return data.map((json) => Manga.fromJson(json)).toList();
  }

  // Métodos para detalhes de anime e mangá
  static Future<Anime> detalhesAnime(int animeId) async {
    final data = await _getSingleData("anime/$animeId/full");
    return Anime.fromJson(data);
  }

  static Future<Manga> detalhesManga(int mangaId) async {
    final data = await _getSingleData("manga/$mangaId/full");
    return Manga.fromJson(data);
  }

  // Método para buscar detalhes de um personagem específico
  static Future<Character> detalhesPersonagem(int characterId) async {
    final data = await _getSingleData("characters/$characterId");
    return Character.fromJson(data);
  }

  // Busca personagem + dubladores em uma única chamada via /characters/{id}/full
  // (a API já retorna "voices" nesse payload, no mesmo formato de
  // /characters/{id}/voices), evitando 2 requisições separadas para a
  // mesma tela de detalhes.
  static Future<(Character, List<Voice>)> detalhesPersonagemComVozes(
    int characterId,
  ) async {
    final data = await _getSingleData("characters/$characterId/full");
    final character = Character.fromJson(data);
    final voices =
        (data['voices'] as List? ?? [])
            .map((json) => Voice.fromJson(json))
            .toList();
    return (character, voices);
  }

  // Métodos para Personagens
  static Future<List<AnimePerson>> buscarPersonagens(int animeId) async {
    final data = await _getListData("anime/$animeId/characters");
    return data
        .map((json) => AnimePerson.fromJson(json))
        .where((p) => p.role == "Main")
        .toList();
  }

  static Future<List<AnimePerson>> buscarTodosPersonagens(int animeId) async {
    final data = await _getListData("anime/$animeId/characters");
    return data.map((json) => AnimePerson.fromJson(json)).toList();
  }

  static Future<List<MangaPerson>> buscarTodosPersonagensM(int mangaId) async {
    final data = await _getListData("manga/$mangaId/characters");
    return data.map((json) => MangaPerson.fromJson(json)).toList();
  }

  static Future<List<MangaPerson>> buscarPersonagensM(int mangaId) async {
    final data = await _getListData("manga/$mangaId/characters");
    return data
        .map((json) => MangaPerson.fromJson(json))
        .where((p) => p.role == "Main")
        .toList();
  }

  // Método para buscar dubladores por idioma
  static Future<List<Voice>> buscarVoiceActors(int characterId) async {
    try {
      final response = await _getWithRetry(
        Uri.parse("$_baseUrl/characters/$characterId/voices"),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return (jsonData['data'] as List)
            .map((json) => Voice.fromJson(json))
            .toList();
      }
      throw Exception("Erro ao buscar dubladores: ${response.statusCode}");
    } catch (e) {
      throw Exception("Erro de conexão ao buscar dubladores: $e");
    }
  }

}
