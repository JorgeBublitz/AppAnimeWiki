# AnimeWiki: catálogo de animes e mangás em Flutter

[![CI](https://github.com/JorgeBublitz/AppAnimeWiki/actions/workflows/ci.yml/badge.svg)](https://github.com/JorgeBublitz/AppAnimeWiki/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)

Aplicativo Android para explorar animes e mangás, seus personagens e os dubladores de cada personagem em vários idiomas. Os dados vêm da [Jikan API](https://jikan.moe/), a API pública do MyAnimeList.

## Funcionalidades

- **Início** com os animes e mangás mais bem avaliados.
- **Catálogo** de animes e mangás com busca por nome e paginação.
- **Detalhes** de cada título: sinopse, nota, ranking, gêneros, episódios ou capítulos.
- **Personagens** principais e lista completa, com busca.
- **Dubladores** de cada personagem, com a bandeira do idioma.
- **Filtro de conteúdo adulto**, com a preferência salva no aparelho.
- **Verificação de conexão** na abertura do app e **cache de imagens** para rolagem suave.

O app tem 10 telas: splash, início, catálogo, detalhes e personagens, cada uma com versão para anime e para mangá.

## Stack

| Uso | Pacotes |
| --- | --- |
| Interface | Flutter, Material, google_fonts |
| Rede | http, connectivity_plus |
| Imagens | cached_network_image, country_icons |
| Persistência local | shared_preferences |
| Qualidade | flutter_test, flutter_lints, GitHub Actions |

## Estrutura

```
lib/
├── api_service.dart   # Chamadas à Jikan API
├── models/            # Anime, mangá, personagens, dubladores (parse do JSON)
├── screens/           # Telas de anime e de mangá
├── widgets/           # Cards, carrossel e seções reutilizáveis
└── colors/            # Paleta do app
test/                  # Testes do parse dos modelos
```

## Como rodar

**Pré-requisitos:** Flutter 3.29 ou superior (Dart 3.7) e um emulador ou aparelho Android.

```bash
git clone https://github.com/JorgeBublitz/AppAnimeWiki.git
cd AppAnimeWiki
flutter pub get
flutter run
```

Testes:

```bash
flutter test
```

> A Jikan API tem limite de requisições por segundo. Se muitas telas forem abertas muito rápido, algumas imagens ou listas podem demorar a carregar.
