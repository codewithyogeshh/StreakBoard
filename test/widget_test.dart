import 'package:flutter_test/flutter_test.dart';
import 'package:streakboard/main.dart';
import 'package:streakboard/models/app_state.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final state = AppState();
    await tester.pumpWidget(StreakBoardApp(appState: state));
    await tester.pump();
    expect(find.byType(StreakBoardApp), findsOneWidget);
  });
}
