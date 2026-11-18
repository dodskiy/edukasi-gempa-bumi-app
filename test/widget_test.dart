import 'package:flutter_test/flutter_test.dart';
import 'package:edukasi_gempa_malut/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SiGempaMalutApp());
    expect(find.byType(SiGempaMalutApp), findsOneWidget);
  });
}
