import 'package:flutter_test/flutter_test.dart';
import 'package:community_polling_app/main.dart';

void main() {
  testWidgets('App smoke test loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const CommunityPollingApp());
    expect(find.byType(CommunityPollingApp), findsOneWidget);
  });
}
