import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../catalog/catalog_models.dart';
import '../catalog/catalog_provider.dart';
import 'part_search_engine.dart';

part 'workbench_filter_provider.freezed.dart';
part 'workbench_filter_provider.g.dart';

@freezed
sealed class WorkbenchFacet with _$WorkbenchFacet {
  const factory WorkbenchFacet.all() = WorkbenchFacetAll;
  const factory WorkbenchFacet.lowStock() = WorkbenchFacetLowStock;
  const factory WorkbenchFacet.unassigned() = WorkbenchFacetUnassigned;
  const factory WorkbenchFacet.category(String category) =
      WorkbenchFacetCategory;
}

class ContainerPartGroup {
  const ContainerPartGroup({
    required this.container,
    required this.title,
    required this.subtitle,
    required this.parts,
  });

  /// `null` for the pinned `Unassigned (Loose / Inbox)` group.
  final Container? container;
  final String title;
  final String? subtitle;
  final List<Part> parts;

  bool get isUnassigned => container == null;
}

class FilteredWorkbenchView {
  const FilteredWorkbenchView({
    required this.flatParts,
    required this.containerGroups,
    required this.availableCategories,
    required this.totalCount,
    required this.lowStockCount,
    required this.unassignedCount,
    required this.containerMap,
  });

  final List<Part> flatParts;
  final List<ContainerPartGroup> containerGroups;
  final List<String> availableCategories;
  final int totalCount;
  final int lowStockCount;
  final int unassignedCount;
  final Map<String, Container> containerMap;
}

@Riverpod(keepAlive: true)
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

@Riverpod(keepAlive: true)
class SelectedFacet extends _$SelectedFacet {
  @override
  WorkbenchFacet build() => const WorkbenchFacet.all();

  void setFacet(WorkbenchFacet facet) {
    state = facet;
  }
}

@Riverpod(keepAlive: true)
class GroupByContainer extends _$GroupByContainer {
  @override
  bool build() => false;

  void setGrouped(bool grouped) {
    state = grouped;
  }

  void toggle() {
    state = !state;
  }
}

@riverpod
FilteredWorkbenchView filteredWorkbenchView(Ref ref) {
  final asyncCatalog = ref.watch(catalogProvider);
  final snapshot = asyncCatalog.value ?? CatalogSnapshot.empty();
  final query = ref.watch(searchQueryProvider);
  final selectedFacet = ref.watch(selectedFacetProvider);

  final containerMap = <String, Container>{
    for (final c in snapshot.containers) c.id: c,
  };

  final availableCategoriesSet = <String>{};
  var lowStockCount = 0;
  var unassignedCount = 0;

  for (final part in snapshot.parts) {
    if (part.isLowStock) lowStockCount++;
    if (part.isUnassigned) unassignedCount++;
    final cat = part.category?.trim();
    if (cat != null && cat.isNotEmpty) {
      availableCategoriesSet.add(cat);
    }
  }
  final availableCategories = availableCategoriesSet.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  // If the selected category facet no longer exists in the catalog, treat as All
  final effectiveFacet = switch (selectedFacet) {
    WorkbenchFacetCategory(:final category)
        when !availableCategoriesSet.any(
          (c) => c.toLowerCase() == category.toLowerCase(),
        ) =>
      const WorkbenchFacet.all(),
    _ => selectedFacet,
  };

  final hasQuery = query.trim().isNotEmpty;
  final hasActiveFacet = effectiveFacet is! WorkbenchFacetAll;

  final scoredParts = <({Part part, int tier})>[];
  for (final part in snapshot.parts) {
    final matchesFacet = switch (effectiveFacet) {
      WorkbenchFacetAll() => true,
      WorkbenchFacetLowStock() => part.isLowStock,
      WorkbenchFacetUnassigned() => part.isUnassigned,
      WorkbenchFacetCategory(:final category) =>
        part.category != null &&
            part.category!.toLowerCase() == category.toLowerCase(),
    };
    if (!matchesFacet) continue;

    final containerName =
        part.containerId == null ? null : containerMap[part.containerId!]?.name;

    if (!hasQuery) {
      scoredParts.add((part: part, tier: 1));
    } else {
      final tier = PartSearchEngine.evaluateQueryRank(
        query: query,
        part: part,
        containerName: containerName,
      );
      if (tier != null) {
        scoredParts.add((part: part, tier: tier));
      }
    }
  }

  scoredParts.sort((a, b) {
    if (hasQuery) {
      final tierCmp = a.tier.compareTo(b.tier);
      if (tierCmp != 0) return tierCmp;
    }
    return a.part.name.toLowerCase().compareTo(b.part.name.toLowerCase());
  });

  final flatParts = scoredParts.map((e) => e.part).toList();

  // Build By Container groups
  final sortedContainers = [...snapshot.containers]
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  final hideEmptyGroups = hasQuery || hasActiveFacet;
  final groups = <ContainerPartGroup>[];

  final unassignedParts = flatParts.where((p) => p.containerId == null).toList();
  if (!hideEmptyGroups || unassignedParts.isNotEmpty) {
    groups.add(
      ContainerPartGroup(
        container: null,
        title: 'Unassigned (Loose / Inbox)',
        subtitle: 'Newly arrived or unfiled workbench parts',
        parts: unassignedParts,
      ),
    );
  }

  for (final container in sortedContainers) {
    final inContainer =
        flatParts.where((p) => p.containerId == container.id).toList();
    if (!hasQuery) {
      inContainer.sort((a, b) {
        final slotCmp = PartSearchEngine.compareNaturalSlot(a.slot, b.slot);
        if (slotCmp != 0) return slotCmp;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    }
    if (!hideEmptyGroups || inContainer.isNotEmpty) {
      groups.add(
        ContainerPartGroup(
          container: container,
          title: container.name,
          subtitle: container.description,
          parts: inContainer,
        ),
      );
    }
  }

  return FilteredWorkbenchView(
    flatParts: flatParts,
    containerGroups: groups,
    availableCategories: availableCategories,
    totalCount: snapshot.parts.length,
    lowStockCount: lowStockCount,
    unassignedCount: unassignedCount,
    containerMap: containerMap,
  );
}
