import 'package:flutter/material.dart';

/// Paleta "OtakuHub" — tema escuro profissional com acento índigo.
///
/// Os nomes das constantes (cor1..cor5, accent1..accent3) foram mantidos
/// para não exigir alterações em todas as telas que já os referenciam;
/// apenas os valores mudaram.
class AppColors {
  // Fundo do splash (variante mais profunda da cor de marca)
  static const Color cor5 = Color(0xFF1E1B4B);

  // Cores principais (fundo)
  static const Color cor1 = Color(0xFF101014); // Fundo escuro principal
  static const Color cor2 = Color(0xFF1B1B23); // Fundo escuro secundário (cards, inputs)
  static const Color cor3 = Color(0xFF242430); // Superfície elevada (barras, chips)
  static const Color cor4 = Color(0xFF6366F1); // Cor de marca (índigo) — destaques e ações

  // Cores complementares
  static const Color accent1 = Color(0xFF14B8A6); // Teal — destaques secundários
  static const Color accent2 = Color(0xFFA855F7); // Roxo — elementos especiais
  static const Color accent3 = Color(0xFF38BDF8); // Azul céu — elementos interativos/links

  // Cores de status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // Cores de texto
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textDisabled = Color(0xFF52525B);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cor3, cor4],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent3, accent2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Sombras
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
}
