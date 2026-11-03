import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parts_tracker_skilled/main.dart';

void main() {
  testWidgets(
    'PartsTrackerApp boots inside ProviderScope with dark theme and WorkbenchScreen shell',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PartsTrackerApp(),
        ),
      );

      expect(find.text('Electronics Parts Tracker'), findsOneWidget);
      expect(find.text('Workbench Ready — 0 parts cataloged'), findsOneWidget);

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);
      expect(
        materialApp.darkTheme?.scaffoldBackgroundColor,
        const Color(0xFF0E1318),
      );
    },
  );
}
