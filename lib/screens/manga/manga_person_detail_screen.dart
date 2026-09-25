import 'package:flutter/material.dart';
import 'package:app/models/manga/manga_person.dart';
import '../../colors/app_colors.dart';
import '../../api/api_service.dart';
import 'package:app/models/character.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MangaPersonDetailScreen extends StatefulWidget {
  final MangaPerson mangaPerson;
  const MangaPersonDetailScreen({super.key, required this.mangaPerson});
  @override
  State<MangaPersonDetailScreen> createState() =>
      _MangaPersonDetailScreenState();
}

class _MangaPersonDetailScreenState extends State<MangaPersonDetailScreen> {
  bool _expandedDesc = false;
  bool _isLoading = true;
  Character? _characterDetails;
  String _errorMessage = '';
  bool _bioExceedsMaxLines = false;

  @override
  void initState() {
    super.initState();
    _carregarDetalhesPersonagem();
  }

  Future<void> _carregarDetalhesPersonagem() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Buscar detalhes completos do personagem
      final detalhes = await ApiService.detalhesPersonagem(
        widget.mangaPerson.character.malId,
      );

      if (mounted) {
        setState(() {
          _characterDetails = detalhes;
          _isLoading = false;

          // Verificar o tamanho da biografia após o próximo frame ser renderizado
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _verificarTamanhoBiografia();
          });
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar detalhes: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Método para verificar se a biografia excede 5 linhas
  void _verificarTamanhoBiografia() {
    if (_characterDetails?.bio == null || _characterDetails!.bio!.isEmpty) {
      setState(() {
        _bioExceedsMaxLines = false;
      });
      return;
    }

    // Calcular aproximadamente se o texto excede 5 linhas
    // Uma abordagem simples é contar caracteres, assumindo ~50 caracteres por linha
    final bioLength = _characterDetails!.bio!.length;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width - 32;

    // Estimativa de caracteres por linha baseada na largura da tela
    final charsPerLine =
        screenWidth / 8; // Aproximadamente 8 pixels por caractere

    setState(() {
      _bioExceedsMaxLines = bioLength > (charsPerLine * 5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cor1,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent3),
                  ),
                )
                : _errorMessage.isNotEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _carregarDetalhesPersonagem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent3,
                        ),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
                : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildSliverSection(_buildHeader()),
                    if (_characterDetails != null &&
                        _characterDetails!.nicknames != null &&
                        _characterDetails!.nicknames!.isNotEmpty)
                      _buildSliverSection(_buildNicknames()),
                    _buildSliverSection(_buildDescription()),
                  ],
                ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    elevation: 0,
    backgroundColor: AppColors.cor4,
    title: const Text(
      'Detalhes do Personagem',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
    centerTitle: true,
  );

  Widget _buildSliverSection(Widget child) => SliverToBoxAdapter(
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );

  Widget _buildHeader() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _MangaPersonImage(widget.mangaPerson),
      const SizedBox(width: 16),
      Expanded(
        child: _MangaPersonBasicInfo(widget.mangaPerson, _characterDetails),
      ),
    ],
  );

  Widget _buildDescription() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle('Biografia'),
      const SizedBox(height: 12),
      _ExpandableDescription(
        // Usando o campo bio do Character detalhado
        _characterDetails?.bio ?? 'Biografia indisponível.',
        _expandedDesc,
        () => setState(() => _expandedDesc = !_expandedDesc),
        showExpandButton: _bioExceedsMaxLines,
      ),
    ],
  );

  Widget _buildNicknames() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle('Apelidos'),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            _characterDetails!.nicknames!.map((nickname) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent3,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent3, width: 1),
                ),
                child: Text(
                  nickname,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
      ),
    ],
  );
}

class _MangaPersonImage extends StatelessWidget {
  final MangaPerson mangaPerson;
  const _MangaPersonImage(this.mangaPerson);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 200,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: mangaPerson.character.images.jpg.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[800]),
              errorWidget:
                  (_, __, ___) => Container(
                    color: const Color.fromARGB(255, 71, 71, 71),
                    child: const Icon(Icons.error, color: Colors.white),
                  ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.record_voice_over,
                    color: AppColors.accent3,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    mangaPerson.role,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MangaPersonBasicInfo extends StatelessWidget {
  final MangaPerson mangaPerson;
  final Character? characterDetails;

  const _MangaPersonBasicInfo(this.mangaPerson, this.characterDetails);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mangaPerson.character.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        if (characterDetails?.kanjiName != null &&
            characterDetails!.kanjiName!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              characterDetails!.kanjiName!,
              style: TextStyle(fontSize: 16, color: Colors.white, height: 1.2),
            ),
          ),
        const SizedBox(height: 12),
        _InfoRow(
          'Favorito',
          (characterDetails?.favorite ?? mangaPerson.favorites).toString(),
        ),
        _InfoRow('ID', mangaPerson.character.malId.toString()),
        _InfoRow('Função', mangaPerson.role),
      ],
    );
  }
}

class _ExpandableDescription extends StatelessWidget {
  final String description;
  final bool isExpanded;
  final VoidCallback onToggle;
  final bool showExpandButton;

  const _ExpandableDescription(
    this.description,
    this.isExpanded,
    this.onToggle, {
    this.showExpandButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: _buildCollapsedDesc(),
          secondChild: _buildExpandedDesc(),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        if (showExpandButton)
          TextButton(
            onPressed: onToggle,
            child: Text(
              isExpanded ? 'Mostrar menos' : 'Mostrar mais',
              style: TextStyle(color: AppColors.accent3),
            ),
          ),
      ],
    );
  }

  Widget _buildCollapsedDesc() => Text(
    description.isNotEmpty ? description : 'Descrição não disponível',
    maxLines: 5,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(color: Colors.white70, height: 1.5),
  );

  Widget _buildExpandedDesc() => Text(
    description,
    style: const TextStyle(color: Colors.white70, height: 1.5),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 24,
          width: 4,
          decoration: BoxDecoration(
            color: AppColors.accent3,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
