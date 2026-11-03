// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workbench_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'201426e1b1170013c4da8239e8e813938d8a8272';

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedFacet)
final selectedFacetProvider = SelectedFacetProvider._();

final class SelectedFacetProvider
    extends $NotifierProvider<SelectedFacet, WorkbenchFacet> {
  SelectedFacetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedFacetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedFacetHash();

  @$internal
  @override
  SelectedFacet create() => SelectedFacet();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkbenchFacet value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkbenchFacet>(value),
    );
  }
}

String _$selectedFacetHash() => r'c39e539fdcc11801992ab58aa009f3fd366e3a74';

abstract class _$SelectedFacet extends $Notifier<WorkbenchFacet> {
  WorkbenchFacet build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WorkbenchFacet, WorkbenchFacet>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WorkbenchFacet, WorkbenchFacet>,
              WorkbenchFacet,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(GroupByContainer)
final groupByContainerProvider = GroupByContainerProvider._();

final class GroupByContainerProvider
    extends $NotifierProvider<GroupByContainer, bool> {
  GroupByContainerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupByContainerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupByContainerHash();

  @$internal
  @override
  GroupByContainer create() => GroupByContainer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$groupByContainerHash() => r'bbd06f85008d74ce94e49cc6b680977102703021';

abstract class _$GroupByContainer extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredWorkbenchView)
final filteredWorkbenchViewProvider = FilteredWorkbenchViewProvider._();

final class FilteredWorkbenchViewProvider
    extends
        $FunctionalProvider<
          FilteredWorkbenchView,
          FilteredWorkbenchView,
          FilteredWorkbenchView
        >
    with $Provider<FilteredWorkbenchView> {
  FilteredWorkbenchViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredWorkbenchViewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredWorkbenchViewHash();

  @$internal
  @override
  $ProviderElement<FilteredWorkbenchView> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FilteredWorkbenchView create(Ref ref) {
    return filteredWorkbenchView(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FilteredWorkbenchView value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FilteredWorkbenchView>(value),
    );
  }
}

String _$filteredWorkbenchViewHash() =>
    r'e2f939375d6c583c88c41d321db61dc444044eef';
