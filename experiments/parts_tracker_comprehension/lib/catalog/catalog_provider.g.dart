// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(catalogPersistence)
final catalogPersistenceProvider = CatalogPersistenceProvider._();

final class CatalogPersistenceProvider
    extends
        $FunctionalProvider<
          CatalogPersistence,
          CatalogPersistence,
          CatalogPersistence
        >
    with $Provider<CatalogPersistence> {
  CatalogPersistenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogPersistenceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogPersistenceHash();

  @$internal
  @override
  $ProviderElement<CatalogPersistence> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CatalogPersistence create(Ref ref) {
    return catalogPersistence(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogPersistence value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogPersistence>(value),
    );
  }
}

String _$catalogPersistenceHash() =>
    r'0da088af834960d7aad31d49127f95441a746150';

@ProviderFor(Catalog)
final catalogProvider = CatalogProvider._();

final class CatalogProvider
    extends $AsyncNotifierProvider<Catalog, CatalogSnapshot> {
  CatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogHash();

  @$internal
  @override
  Catalog create() => Catalog();
}

String _$catalogHash() => r'e13bcac658f8bd010dc3843bfe1bed69fd33b6a1';

abstract class _$Catalog extends $AsyncNotifier<CatalogSnapshot> {
  FutureOr<CatalogSnapshot> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CatalogSnapshot>, CatalogSnapshot>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CatalogSnapshot>, CatalogSnapshot>,
              AsyncValue<CatalogSnapshot>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
