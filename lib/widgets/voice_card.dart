import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/dublagem/voice.dart';
import '../colors/app_colors.dart';

class VoiceCard extends StatelessWidget {
  final Voice voice;
  final bool compactMode;
  final VoidCallback? onTap;

  const VoiceCard({
    super.key,
    required this.voice,
    this.compactMode = false,
    this.onTap,
  });

  /// Retorna o código ISO do país correspondente ao idioma
  String? _getCountryCode(String lang) {
    switch (lang.toLowerCase()) {
      case 'japanese':
        return 'jp';
      case 'english':
        return 'us';
      case 'spanish':
        return 'es';
      case 'portuguese':
        return 'pt';
      case 'portuguese (br)':
        return 'br';
      case 'french':
        return 'fr';
      case 'german':
        return 'de';
      case 'italian':
        return 'it';
      case 'russian':
        return 'ru';
      case 'korean':
        return 'kr';
      case 'chinese':
        return 'cn';
      case 'dutch':
        return 'nl';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = compactMode ? 100 : 110;
    final String? countryCode = _getCountryCode(voice.language);

    return SizedBox(
      width: cardWidth,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white24,
          onTap: onTap ?? () {},
          child: Stack(
            children: [
              // Imagem do dublador
              AspectRatio(
                aspectRatio: 3 / 4,
                child: CachedNetworkImage(
                  imageUrl: voice.person.images.jpg.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.cor2),
                  errorWidget:
                      (_, __, ___) => Container(
                        color: AppColors.cor1,
                        child: const Center(
                          child: Icon(
                            Icons.person_off,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                ),
              ),

              // Bandeira do idioma
              if (countryCode != null)
                Positioned(
                  top: 6,
                  left: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'icons/flags/png/$countryCode.png',
                      package: 'country_icons',
                      width: compactMode ? 20 : 26,
                      height: compactMode ? 14 : 18,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              // Nome do dublador
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(color: Colors.black),
                  child: Text(
                    voice.person.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compactMode ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
