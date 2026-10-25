import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hammesh_aae/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('home loads', (tester) async {
    await tester.pumpWidget(const GsssbAaeApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Your Progress'), findsOneWidget);
  });
}
