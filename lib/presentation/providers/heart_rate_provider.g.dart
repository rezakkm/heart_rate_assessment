// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heart_rate_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$heartRateDataSourceHash() =>
    r'02aff915637e7f3ac42aace3d0c4c9c553f2da4a';

/// Provider for the heart rate data source
///
/// Copied from [heartRateDataSource].
@ProviderFor(heartRateDataSource)
final heartRateDataSourceProvider =
    AutoDisposeProvider<HeartRateDataSource>.internal(
  heartRateDataSource,
  name: r'heartRateDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$heartRateDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HeartRateDataSourceRef = AutoDisposeProviderRef<HeartRateDataSource>;
String _$heartRateRepositoryHash() =>
    r'68e9de9942ac53ae346db6ba047375b2a17322c7';

/// Provider for the heart rate repository
///
/// Copied from [heartRateRepository].
@ProviderFor(heartRateRepository)
final heartRateRepositoryProvider =
    AutoDisposeProvider<HeartRateRepository>.internal(
  heartRateRepository,
  name: r'heartRateRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$heartRateRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HeartRateRepositoryRef = AutoDisposeProviderRef<HeartRateRepository>;
String _$heartRateStreamHash() => r'50b94a6c55c19e1c40c1e3f8fc2fef234858868f';

/// Provider for the heart rate stream
///
/// Copied from [heartRateStream].
@ProviderFor(heartRateStream)
final heartRateStreamProvider =
    AutoDisposeStreamProvider<Either<Failure, HeartRateEntity>>.internal(
  heartRateStream,
  name: r'heartRateStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$heartRateStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HeartRateStreamRef
    = AutoDisposeStreamProviderRef<Either<Failure, HeartRateEntity>>;
String _$heartRateMonitoringHash() =>
    r'89ff1c27fc166c0bb7f9a5451e1f1459a4cd05d0';

/// Provider for the heart rate monitoring state
///
/// Copied from [HeartRateMonitoring].
@ProviderFor(HeartRateMonitoring)
final heartRateMonitoringProvider =
    AutoDisposeNotifierProvider<HeartRateMonitoring, bool>.internal(
  HeartRateMonitoring.new,
  name: r'heartRateMonitoringProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$heartRateMonitoringHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HeartRateMonitoring = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
