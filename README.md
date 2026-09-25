# AniCodex: catálogo de animes e mangás em Flutter

[![CI](https://github.com/JorgeBublitz/AppAnimeWiki/actions/workflows/ci.yml/badge.svg)](https://github.com/JorgeBublitz/AppAnimeWiki/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)

> **⚠️ Aviso:** o app ainda consome a [Jikan API](https://jikan.moe/), a API pública não-oficial do MyAnimeList. O mantenedor anunciou a **descontinuação do endpoint público** (`api.jikan.moe`): modo de manutenção desde jun/2026, instabilidade/outages desde ago/2026 e desligamento definitivo em **01/10/2026**. A versão anterior à migração fica marcada como `v1` (tag `v1`) para referência histórica; a migração para uma nova fonte de dados está em andamento nesta branch (`v2`).

Aplicativo Android/Web para explorar animes e mangás, seus personagens e os dubladores de cada personagem em vários idiomas. Os dados vêm da [Jikan API](https://jikan.moe/), a API pública do MyAnimeList (em migração — veja aviso acima).

## Funcionalidades

- **Início** com os animes e mangás mais bem avaliados, alternando entre abas Anime/Mangá.
- **Catálogo** de animes e mangás com busca por nome e rolagem infinita.
- **Detalhes** de cada título: sinopse, nota, ranking, gêneros, episódios ou capítulos.
- **Personagens** principais e lista completa, com busca.
- **Dubladores** de cada personagem, com a bandeira do idioma.
- **Perfil**: fluxo de login/cadastro pré-preparado para quando houver uma API de contas.
- **Verificação de conexão** na abertura do app e **cache de imagens** para rolagem suave.

O app tem splash, início, catálogo, detalhes, personagens (cada uma com versão para anime e para mangá), além de perfil, login e cadastro.

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
├── api/                # Chamadas à Jikan/AniList (a "camada de backend" do app,
│                       # já que ele consome APIs externas em vez de ter servidor próprio)
├── models/             # Anime, mangá, personagens, dubladores (parse do JSON)
├── screens/            # Telas de anime e de mangá — a interface (front-end) do app
├── widgets/            # Cards, carrossel e seções reutilizáveis
├── colors/             # Paleta do app
└── routes.dart         # Nomes centralizados das rotas de tela
test/                    # Testes do parse dos modelos
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
