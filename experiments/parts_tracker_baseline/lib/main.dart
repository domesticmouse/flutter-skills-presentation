import 'package:flutter/material.dart';

import 'data/repositories/parts_repository.dart';
import 'data/services/local_storage_service.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/inventory/view_models/inventory_view_model.dart';
import 'ui/features/inventory/views/inventory_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = PartsRepository(
    storageService: FileLocalStorageService(),
  );
  final viewModel = InventoryViewModel(repository: repository)..loadInventory();
  runApp(PartsTrackerApp(viewModel: viewModel));
}

/// Root widget for the Electronics Parts Tracker application.
class PartsTrackerApp extends StatelessWidget {
  const PartsTrackerApp({
    super.key,
    required this.viewModel,
  });

  final InventoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return MaterialApp(
          title: 'PartsBench',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: viewModel.themeMode,
          home: InventoryHomeScreen(viewModel: viewModel),
        );
      },
    );
  }
}
