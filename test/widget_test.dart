import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:all_cheese/main.dart';
import 'package:all_cheese/providers/game_provider.dart';

void main() {
  testWidgets('App launches and shows setup screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GameProvider(),
        child: const AllCheeseApp(),
      ),
    );
    await tester.pump();
    expect(find.text('All Cheese'), findsOneWidget);
  });
}
