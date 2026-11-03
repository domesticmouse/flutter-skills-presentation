import 'package:flutter/material.dart';

import '../../../../data/repositories/parts_repository.dart';
import '../../../../domain/models/electronic_part.dart';
import '../../../../domain/models/part_category.dart';
import '../../../../domain/models/storage_location_summary.dart';

/// Filter options for part stock levels.
enum StockFilter {
  all('All Stock'),
  needsRestock('Low / Out of Stock'),
  outOfStock('Out of Stock Only');

  const StockFilter(this.label);
  final String label;
}

/// Sort order options for the inventory list.
enum PartSortOrder {
  nameAsc('Name (A–Z)'),
  quantityAsc('Quantity (Low to High)'),
  quantityDesc('Quantity (High to Low)'),
  category('Category'),
  location('Storage Location'),
  recentlyUpdated('Recently Updated');

  const PartSortOrder(this.label);
  final String label;
}

/// ViewModel managing the state and user actions for the parts inventory.
class InventoryViewModel extends ChangeNotifier {
  InventoryViewModel({required this._repository});

  final PartsRepository _repository;

  List<ElectronicPart> _allParts = const [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  PartCategory? _selectedCategory;
  StockFilter _stockFilter = StockFilter.all;
  String? _selectedLocation;
  PartSortOrder _sortOrder = PartSortOrder.nameAsc;
  ThemeMode _themeMode = ThemeMode.system;

  List<ElectronicPart>? _filteredPartsCache;
  List<ElectronicPart>? _restockPartsCache;
  List<String>? _distinctLocationNamesCache;
  List<StorageLocationSummary>? _locationSummariesCache;

  List<ElectronicPart> get allParts => _allParts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  PartCategory? get selectedCategory => _selectedCategory;
  StockFilter get stockFilter => _stockFilter;
  String? get selectedLocation => _selectedLocation;
  PartSortOrder get sortOrder => _sortOrder;
  ThemeMode get themeMode => _themeMode;

  void _updateAllParts(List<ElectronicPart> parts) {
    _allParts = parts;
    _filteredPartsCache = null;
    _restockPartsCache = null;
    _distinctLocationNamesCache = null;
    _locationSummariesCache = null;
  }

  static String _normalizeDisplayLocation(String rawLocation) {
    final trimmed = rawLocation.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'unassigned') {
      return 'Unassigned';
    }
    return trimmed;
  }

  /// Total number of distinct part types in inventory.
  int get totalDistinctParts => _allParts.length;

  /// Total quantity of individual components across all parts.
  int get totalUnitsCount =>
      _allParts.fold<int>(0, (sum, part) => sum + part.quantity);

  /// Number of parts at or below their minimum stock threshold.
  int get restockCount => restockParts.length;

  /// Number of parts with zero quantity.
  int get outOfStockCount =>
      _allParts.where((part) => part.isOutOfStock).length;

  /// Estimated total monetary value of all parts in stock.
  double get totalInventoryValue =>
      _allParts.fold<double>(0.0, (sum, part) => sum + part.totalValue);

  /// Parts that are either low on stock or out of stock, sorted by lowest stock first.
  List<ElectronicPart> get restockParts {
    final cached = _restockPartsCache;
    if (cached != null) return cached;

    final list = _allParts.where((part) => part.needsRestock).toList();
    list.sort((a, b) {
      final qtyCmp = a.quantity.compareTo(b.quantity);
      if (qtyCmp != 0) return qtyCmp;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    final unmodifiable = List<ElectronicPart>.unmodifiable(list);
    _restockPartsCache = unmodifiable;
    return unmodifiable;
  }

  /// Distinct non-empty storage location names currently used across parts.
  List<String> get distinctLocationNames {
    final cached = _distinctLocationNamesCache;
    if (cached != null) return cached;

    final locations = _allParts
        .map((p) => p.storageLocation.trim())
        .where((loc) => loc.isNotEmpty && loc.toLowerCase() != 'unassigned')
        .toSet()
        .toList();
    locations.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final unmodifiable = List<String>.unmodifiable(locations);
    _distinctLocationNamesCache = unmodifiable;
    return unmodifiable;
  }

  /// Aggregated summaries for all storage locations.
  List<StorageLocationSummary> get locationSummaries {
    final cached = _locationSummariesCache;
    if (cached != null) return cached;

    final grouped = <String, List<ElectronicPart>>{};
    for (final part in _allParts) {
      final loc = _normalizeDisplayLocation(part.storageLocation);
      grouped.putIfAbsent(loc, () => <ElectronicPart>[]).add(part);
    }

    final summaries = grouped.entries
        .map(
          (entry) => StorageLocationSummary(
            locationName: entry.key,
            parts: List<ElectronicPart>.unmodifiable(entry.value),
          ),
        )
        .toList();

    summaries.sort((a, b) {
      if (a.locationName == 'Unassigned') return 1;
      if (b.locationName == 'Unassigned') return -1;
      return a.locationName
          .toLowerCase()
          .compareTo(b.locationName.toLowerCase());
    });
    final unmodifiable = List<StorageLocationSummary>.unmodifiable(summaries);
    _locationSummariesCache = unmodifiable;
    return unmodifiable;
  }

  /// Parts filtered by current search query, category, stock filter, and location,
  /// and sorted according to [sortOrder].
  List<ElectronicPart> get filteredParts {
    final cached = _filteredPartsCache;
    if (cached != null) return cached;

    final filtered = _allParts.where((part) {
      if (_selectedCategory != null && part.category != _selectedCategory) {
        return false;
      }

      if (_selectedLocation != null) {
        final normalizedPartLoc =
            _normalizeDisplayLocation(part.storageLocation);
        if (normalizedPartLoc != _selectedLocation) {
          return false;
        }
      }

      switch (_stockFilter) {
        case StockFilter.all:
          break;
        case StockFilter.needsRestock:
          if (!part.needsRestock) return false;
        case StockFilter.outOfStock:
          if (!part.isOutOfStock) return false;
      }

      return part.matchesQuery(_searchQuery);
    }).toList();

    filtered.sort((a, b) {
      switch (_sortOrder) {
        case PartSortOrder.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case PartSortOrder.quantityAsc:
          final cmp = a.quantity.compareTo(b.quantity);
          return cmp != 0
              ? cmp
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case PartSortOrder.quantityDesc:
          final cmp = b.quantity.compareTo(a.quantity);
          return cmp != 0
              ? cmp
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case PartSortOrder.category:
          final cmp = a.category.label.compareTo(b.category.label);
          return cmp != 0
              ? cmp
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case PartSortOrder.location:
          final locA = a.storageLocation.trim().toLowerCase();
          final locB = b.storageLocation.trim().toLowerCase();
          final cmp = locA.compareTo(locB);
          return cmp != 0
              ? cmp
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case PartSortOrder.recentlyUpdated:
          return b.updatedAt.compareTo(a.updatedAt);
      }
    });

    final unmodifiable = List<ElectronicPart>.unmodifiable(filtered);
    _filteredPartsCache = unmodifiable;
    return unmodifiable;
  }

  /// Whether any filter or search query is currently active.
  bool get hasActiveFilters =>
      _searchQuery.trim().isNotEmpty ||
      _selectedCategory != null ||
      _stockFilter != StockFilter.all ||
      _selectedLocation != null;

  /// Looks up a single part by [id], or returns `null` if not found.
  ElectronicPart? getPartById(String id) {
    for (final part in _allParts) {
      if (part.id == id) return part;
    }
    return null;
  }

  /// Clears any active error message.
  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Loads the parts inventory from the repository.
  Future<void> loadInventory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _updateAllParts(await _repository.getParts());
    } on Object catch (e) {
      _errorMessage = 'Failed to load inventory: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds or updates a part.
  Future<void> savePart(ElectronicPart part) async {
    _errorMessage = null;
    try {
      _updateAllParts(await _repository.savePart(part));
      notifyListeners();
    } on Object catch (e) {
      _errorMessage = 'Failed to save part: $e';
      notifyListeners();
    }
  }

  /// Deletes a part by [id].
  Future<void> deletePart(String id) async {
    _errorMessage = null;
    try {
      _updateAllParts(await _repository.deletePart(id));
      notifyListeners();
    } on Object catch (e) {
      _errorMessage = 'Failed to delete part: $e';
      notifyListeners();
    }
  }

  /// Adjusts the quantity of a part by [delta].
  Future<void> adjustQuantity(String id, int delta) async {
    _errorMessage = null;
    try {
      _updateAllParts(await _repository.adjustQuantity(id, delta));
      notifyListeners();
    } on Object catch (e) {
      _errorMessage = 'Failed to update quantity: $e';
      notifyListeners();
    }
  }

  /// Sets the exact stock quantity of a part.
  Future<void> setExactQuantity(String id, int newQuantity) async {
    final part = getPartById(id);
    if (part == null) return;
    final clamped = newQuantity < 0 ? 0 : newQuantity;
    await savePart(
      part.copyWith(
        quantity: clamped,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  /// Renames a storage location across all parts in that location.
  Future<void> renameLocation({
    required String oldLocation,
    required String newLocation,
  }) async {
    _errorMessage = null;
    try {
      final normalizedOld = _normalizeDisplayLocation(oldLocation);
      final normalizedNew = _normalizeDisplayLocation(newLocation);
      _updateAllParts(
        await _repository.renameLocation(
          oldLocation: oldLocation,
          newLocation: newLocation,
        ),
      );
      if (_selectedLocation == normalizedOld) {
        _selectedLocation = normalizedNew;
        _filteredPartsCache = null;
      }
      notifyListeners();
    } on Object catch (e) {
      _errorMessage = 'Failed to rename location: $e';
      notifyListeners();
    }
  }

  /// Resets the inventory to default starter parts.
  Future<void> resetToSampleData() async {
    _errorMessage = null;
    try {
      _updateAllParts(await _repository.resetToSampleData());
      clearFilters();
    } on Object catch (e) {
      _errorMessage = 'Failed to reset sample data: $e';
      notifyListeners();
    }
  }

  /// Exports all parts as a JSON string.
  Future<String> exportJson() => _repository.exportJson();

  /// Exports all parts as a CSV string.
  Future<String> exportCsv() => _repository.exportCsv();

  /// Imports parts from JSON or CSV text and returns the number of imported records.
  Future<int> importData({
    required String content,
    required bool isCsv,
    required bool replaceExisting,
  }) async {
    _errorMessage = null;
    _updateAllParts(
      await _repository.importData(
        content: content,
        isCsv: isCsv,
        replaceExisting: replaceExisting,
      ),
    );
    notifyListeners();
    return _repository.lastImportedCount;
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _filteredPartsCache = null;
    notifyListeners();
  }

  void setSelectedCategory(PartCategory? category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _filteredPartsCache = null;
    notifyListeners();
  }

  void setStockFilter(StockFilter filter) {
    if (_stockFilter == filter) return;
    _stockFilter = filter;
    _filteredPartsCache = null;
    notifyListeners();
  }

  void setSelectedLocation(String? location) {
    final normalized =
        location == null ? null : _normalizeDisplayLocation(location);
    if (_selectedLocation == normalized) return;
    _selectedLocation = normalized;
    _filteredPartsCache = null;
    notifyListeners();
  }

  void setSortOrder(PartSortOrder order) {
    if (_sortOrder == order) return;
    _sortOrder = order;
    _filteredPartsCache = null;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _stockFilter = StockFilter.all;
    _selectedLocation = null;
    _filteredPartsCache = null;
    notifyListeners();
  }

  void toggleThemeMode() {
    _themeMode = switch (_themeMode) {
      ThemeMode.system => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.system,
    };
    notifyListeners();
  }
}
