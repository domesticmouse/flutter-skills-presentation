import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog/catalog_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: PartsTrackerApp(),
    ),
  );
}

class PartsTrackerApp extends StatelessWidget {
  const PartsTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electronics Parts Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0E1318),
      ),
      home: const WorkbenchScreen(),
    );
  }
}

class WorkbenchScreen extends ConsumerWidget {
  const WorkbenchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCatalog = ref.watch(catalogProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electronics Parts Tracker'),
      ),
      body: Center(
        child: switch (asyncCatalog) {
          AsyncData(:final value) => Text(
              'Workbench Ready — ${value.parts.length} parts cataloged',
            ),
          AsyncError(:final error) => Text('Error loading catalog: $error'),
          _ => const CircularProgressIndicator(),
        },
      ),
    );
  }
}
