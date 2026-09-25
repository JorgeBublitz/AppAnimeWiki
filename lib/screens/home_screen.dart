// lib/screens/home_screen.dart
import 'package:app/screens/anime/all_anime_screen.dart';
import 'package:app/screens/manga/all_manga_screen.dart';
import 'package:flutter/material.dart';
import '../models/anime/anime.dart';
import '../models/manga/manga.dart';
import '../widgets/cards_anime/anime_card.dart';
import '../widgets/cards_manga/manga_card.dart';
import '../colors/app_colors.dart';
import '../screens/anime/anime_detail_screen.dart';
import '../screens/manga/manga_detail_screen.dart';
import '../widgets/feature_carousel.dart';
import '../widgets/category_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final List<Anime> animes;
  final List<Manga> mangas;

  const HomeScreen({super.key, required this.animes, required this.mangas});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late List<Anime> _filteredAnimes;
  late List<Manga> _filteredMangas;
  late List<Anime> _featuredAnimes;
  late List<Anime> _actionAnimes;
  late List<Manga> _popularMangas;
  late List<Anime> _topAnimes;
  late List<Manga> _topMangas;
  bool _isAdultContentEnabled = false;
  bool _isLoading = true;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPreferences();
    _initializeData();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAdultContentEnabled = prefs.getBool('adultContentEnabled') ?? false;
    });
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Filtrar animes e mangás com base na configuração de conteúdo adulto
      _filteredAnimes = _filterContent(widget.animes);
      _filteredMangas = _filterContent(widget.mangas);

      // Obter animes em destaque (top 5 por popularidade)
      final sortedAnimesByPopularity = List<Anime>.from(_filteredAnimes)
        ..sort((a, b) => a.popularity.compareTo(b.popularity));
      _featuredAnimes = sortedAnimesByPopularity.take(5).toList();

      // Obter animes de ação
      _actionAnimes =
          _filteredAnimes
              .where(
                (anime) => anime.genres.any(
                  (genre) => genre.name.toLowerCase().contains('action'),
                ),
              )
              .take(10)
              .toList();

      // Obter mangás populares
      final sortedMangasByPopularity = List<Manga>.from(_filteredMangas)
        ..sort((a, b) => a.popularity.compareTo(b.popularity));
      _popularMangas = sortedMangasByPopularity.take(10).toList();

      // Obter Top 10 animes e mangás por rank (sem mutar as listas filtradas)
      final sortedAnimesByRank = List<Anime>.from(_filteredAnimes)
        ..sort((a, b) => a.rank.compareTo(b.rank));
      _topAnimes = sortedAnimesByRank.take(10).toList();

      final sortedMangasByRank = List<Manga>.from(_filteredMangas)
        ..sort((a, b) => a.rank.compareTo(b.rank));
      _topMangas = sortedMangasByRank.take(10).toList();
    } catch (e) {
      debugPrint('Erro ao inicializar dados: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<T> _filterContent<T>(List<T> items) {
    if (_isAdultContentEnabled) {
      return items;
    } else {
      if (T == Anime) {
        return items
            .where(
              (item) =>
                  (item as Anime).rating != 'R+ - Mild Nudity' &&
                  (item as Anime).rating != 'Rx - Hentai',
            )
            .toList();
      } else if (T == Manga) {
        return items;
      }
      return items;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cor1,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingIndicator() : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 4,
      backgroundColor: AppColors.cor1,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.account_circle_rounded, color: Colors.white, size: 28),
          SizedBox(width: 8),
          Text(
            'Otaku Hub',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 30,
              color: Colors.white,
              letterSpacing: 1.5,
              wordSpacing: 2,
              fontFamily: 'Montserrat',
              shadows: [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
      centerTitle: true,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade400,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: 'RobotoMono',
          letterSpacing: 0.5,
        ),
        tabs: const [Tab(text: 'Animes'), Tab(text: 'Mangás')],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.cor4),
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [_buildAnimeTab(), _buildMangaTab()],
    );
  }

  Widget _buildAnimeTab() {
    return RefreshIndicator(
      onRefresh: _initializeData,
      color: AppColors.cor4,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner de destaque
              FeatureCarousel(animes: _featuredAnimes),

              const SizedBox(height: 24),

              // Seção Top 10 Animes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _sectionTitle("Top 10 Animes"),
                    const Spacer(),
                    _buttonSection("Ver mais", isAnime: true),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildHorizontalList(_topAnimes, isAnime: true),

              const SizedBox(height: 24),

              // Seção Animes de Ação
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _sectionTitle("Animes de Ação"),
              ),
              const SizedBox(height: 12),
              _buildHorizontalList(_actionAnimes, isAnime: true),

              const SizedBox(height: 24),

              // Seção Lançamentos da Temporada
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _sectionTitle("Lançamentos da Temporada"),
              ),
              const SizedBox(height: 12),
              CategorySection(
                items:
                    _filteredAnimes
                        .where((anime) => anime.status == "Currently Airing")
                        .take(6)
                        .toList(),
                isAnime: true,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMangaTab() {
    return RefreshIndicator(
      onRefresh: _initializeData,
      color: AppColors.cor4,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção Top 10 Mangás
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _sectionTitle("Top 10 Mangás"),
                    const Spacer(),
                    _buttonSection("Ver mais", isAnime: false),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildHorizontalList(_topMangas, isAnime: false),

              const SizedBox(height: 24),

              // Seção Mangás Populares
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _sectionTitle("Mangás Populares"),
              ),
              const SizedBox(height: 12),
              _buildHorizontalList(_popularMangas, isAnime: false),

              const SizedBox(height: 24),

              // Seção Em Publicação
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _sectionTitle("Em Publicação"),
              ),
              const SizedBox(height: 12),
              CategorySection(
                items:
                    _filteredMangas
                        .where((manga) => manga.publishing)
                        .take(6)
                        .toList(),
                isAnime: false,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buttonSection(String title, {required bool isAnime}) {
    return InkWell(
      onTap: () {
        if (isAnime) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AllAnimeScreen(initialAnimes: _filteredAnimes),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AllMangaScreen(initialMangas: _filteredMangas),
            ),
          );
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<dynamic> lista, {required bool isAnime}) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: lista.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final item = lista[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            isAnime
                                ? AnimeDetailScreen(anime: item as Anime)
                                : MangaDetailScreen(manga: item as Manga),
                  ),
                );
              },
              child: SizedBox(
                width: 140,
                child:
                    isAnime
                        ? AnimeCard(anime: item as Anime, showRank: true)
                        : MangaCard(manga: item as Manga, showRank: true),
              ),
            ),
          );
        },
      ),
    );
  }
}
