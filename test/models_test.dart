import 'dart:convert';

import 'package:app/models/anime/anime.dart';
import 'package:app/models/manga/manga.dart';
import 'package:flutter_test/flutter_test.dart';

// Testes do parse dos modelos com respostas no formato da Jikan API v4.
void main() {
  group('Manga.fromJson', () {
    test('lê um mangá completo, com autores na chave "authors"', () {
      final manga = Manga.fromJson(jsonDecode('''
        {
          "mal_id": 2, "url": "https://myanimelist.net/manga/2",
          "images": {"jpg": {"image_url": "https://img/2.jpg"}},
          "title": "Berserk", "type": "Manga", "chapters": null, "volumes": null,
          "status": "Publishing", "publishing": true, "score": 9.47, "scored_by": 350000,
          "rank": 1, "popularity": 2, "members": 700000, "favorites": 130000,
          "title_synonyms": ["Berserk: The Prototype"],
          "genres": [{"mal_id": 1, "name": "Action"}],
          "authors": [{"mal_id": 1868, "name": "Miura, Kentarou"}]
        }
      ''') as Map<String, dynamic>);

      expect(manga.title, 'Berserk');
      expect(manga.author, 'Miura, Kentarou');
      expect(manga.score, 9.47);
      expect(manga.genres.single.name, 'Action');
    });

    test('não quebra com campos nulos e nota inteira', () {
      final manga = Manga.fromJson(jsonDecode('''
        {
          "mal_id": 99, "url": "https://myanimelist.net/manga/99",
          "images": {"jpg": {"image_url": "https://img/99.jpg"}},
          "title": "Lançamento", "type": null, "status": "Publishing", "publishing": true,
          "score": null, "scored_by": null, "rank": null, "popularity": 50000,
          "members": 10, "favorites": 0, "title_synonyms": [], "genres": [], "authors": []
        }
      ''') as Map<String, dynamic>);

      expect(manga.score, 0);
      expect(manga.rank, 0);
      expect(manga.type, '');
      expect(manga.author, 'Autor desconhecido');

      final comNotaInteira = Manga.fromJson({'title': 'X', 'score': 8});
      expect(comNotaInteira.score, 8.0);
    });
  });

  group('Anime.fromJson', () {
    test('lê um anime e aceita nota inteira ou nula', () {
      final anime = Anime.fromJson({
        'mal_id': 1,
        'title': 'Cowboy Bebop',
        'images': {
          'jpg': {'image_url': 'https://img/1.jpg'},
        },
        'score': 9,
        'episodes': 26,
        'genres': [
          {'mal_id': 1, 'name': 'Action'},
        ],
      });

      expect(anime.title, 'Cowboy Bebop');
      expect(anime.score, 9.0);
      expect(anime.episodes, 26);
      expect(anime.images.jpg.imageUrl, 'https://img/1.jpg');

      expect(Anime.fromJson({'title': 'Novo', 'score': null}).score, 0);
    });
  });
}
