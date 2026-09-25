// Teste de fumaça (smoke test) do app.
//
// Verifica que o MyApp sobe sem lançar exceções e que a SplashScreen
// (tela inicial) é exibida.

import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';
import 'package:app/screens/splash_screen.dart';

void main() {
  testWidgets('MyApp inicia e exibe a SplashScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('AniCodex'), findsOneWidget);

    // A SplashScreen dispara Future.delayed e um AnimationController que se
    // repete indefinidamente; avançamos o relógio manualmente (em vez de
    // pumpAndSettle, que nunca se estabilizaria) para esvaziar os timers
    // pendentes antes do fim do teste.
    await tester.pump(const Duration(seconds: 1));
  });
}
