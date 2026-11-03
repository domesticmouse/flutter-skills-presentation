// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lcsc_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lcscClient)
final lcscClientProvider = LcscClientProvider._();

final class LcscClientProvider
    extends $FunctionalProvider<LcscClient, LcscClient, LcscClient>
    with $Provider<LcscClient> {
  LcscClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lcscClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lcscClientHash();

  @$internal
  @override
  $ProviderElement<LcscClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LcscClient create(Ref ref) {
    return lcscClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LcscClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LcscClient>(value),
    );
  }
}

String _$lcscClientHash() => r'3a64b6506c6a55f44f442a81ee15a7668b74a77d';
