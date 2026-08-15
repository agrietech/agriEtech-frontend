import 'package:flutter_test/flutter_test.dart';
import 'package:agrietech_ewa_app/app.dart';

void main() {
  testWidgets('AgriEtechApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriEtechApp());
    expect(find.text('AgriEtech Early Warning Platform'), findsWidgets);
  });
}
