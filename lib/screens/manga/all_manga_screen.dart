import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/colors/app_colors.dart';
import 'package:app/widgets/cards_manga/manga_card.dart';
import 'package:app/models/manga/manga.dart';
import 'package:app/screens/manga/manga_detail_screen.dart';
import 'package:app/api/api_service.dart';

class AllMangaScreen extends StatefulWidget {
  final List<Manga> initialMangas;
  const AllMangaScreen({super.key, required this.initialMangas});

  @override
  State<AllMangaScreen> createState() => _AllMangaScreenState();
}

class _AllMangaScreenState extends State<AllMangaScreen> {
  final List<Manga> _mangas = [];
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 24;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounce;

  Future<void> _fetchPage(int page, {String query = '', bool append = false}) async {
    if (append) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() => _isLoading = true);
    }

    try {
      final result = await ApiService.fetchMangas(
        page: page,
        limit: _itemsPerPage,
        query: query,
        sfw: true,
      );

      if (mounted) {
        setState(() {
          if (append) {
            _mangas.addAll(result['mangas'] as List<Manga>? ?? []);
          } else {
            _mangas
              ..clear()
              ..addAll(result['mangas'] as List<Manga>? ?? []);
          }
          _currentPage = page;
          _totalPages = result['totalPages'] ?? 1;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_isLoading || _isLoadingMore) return;
    if (_currentPage >= _totalPages) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _fetchPage(_currentPage + 1, query: _searchQuery, append: true);
    }
  }

  void _onSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != query) {
        _searchQuery = query;
        _fetchPage(1, query: query);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPage(_currentPage);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cor1,
      appBar: AppBar(
        backgroundColor: AppColors.cor1,
        elevation: 0,
        titleSpacing: 0,
        title: _SearchField(
          controller: _searchController,
          hint: 'Pesquisar mangás...',
          onChanged: _onSearchChanged,
          onClear: () {
            _searchController.clear();
            _searchQuery = '';
            _fetchPage(1);
          },
        ),
      ),
      body: SafeArea(child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return _buildLoadingScreen();
    if (_mangas.isEmpty) return _buildEmptyScreen();
    return _buildMangaGrid();
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.cor4),
    );
  }

  Widget _buildEmptyScreen() {
    return Center(
      child: Text(
        'Nenhum mangá encontrado.',
        style: GoogleFonts.inter(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildMangaGrid() {
    return RefreshIndicator(
      onRefresh: () => _fetchPage(1, query: _searchQuery),
      color: AppColors.cor4,
      child: GridView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 20,
          childAspectRatio: 0.52,
        ),
        itemCount: _mangas.length + (_isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= _mangas.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(color: AppColors.cor4, strokeWidth: 2),
              ),
            );
          }
          final manga = _mangas[index];
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              if (manga.malId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MangaDetailScreen(manga: manga)),
                );
              }
            },
            child: MangaCard(manga: manga),
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.cor2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: AppColors.textDisabled, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 18),
            onPressed: onClear,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
