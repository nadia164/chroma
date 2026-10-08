import 'package:flutter_test/flutter_test.dart';

import 'package:chroma/main.dart';
import 'package:chroma/services/theme_controller.dart';

void main() {
  testWidgets('Chroma app loads', (WidgetTester tester) async {
    final themeController = ThemeController();

    await themeController.load();

    await tester.pumpWidget(ChromaApp(themeController: themeController));

    expect(find.text('CHROMA'), findsOneWidget);
    expect(find.text('Turn a feeling\ninto color.'), findsOneWidget);
  });
}
