import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/heart_rate_entity.dart';
import '../../domain/repositories/heart_rate_repository.dart';
import '../../data/repositories/heart_rate_repository_impl.dart';
import '../../data/datasources/heart_rate_data_source.dart';

part 'heart_rate_provider.g.dart';

/// Provider for the heart rate data source
@riverpod
HeartRateDataSource heartRateDataSource(Ref ref) {
  return HeartRateDataSourceImpl();
}

/// Provider for the heart rate repository
@riverpod
HeartRateRepository heartRateRepository(Ref ref) {
  final dataSource = ref.watch(heartRateDataSourceProvider);
  return HeartRateRepositoryImpl(dataSource);
}

/// Provider for the heart rate stream
@riverpod
Stream<Either<Failure, HeartRateEntity>> heartRateStream(
    HeartRateStreamRef ref) {
  final repository = ref.watch(heartRateRepositoryProvider);
  return repository.getHeartRateStream();
}

/// Provider for the heart rate monitoring state
@riverpod
class HeartRateMonitoring extends _$HeartRateMonitoring {
  @override
  bool build() {
    return false; // Initially not monitoring
  }

  /// Start heart rate monitoring
  Future<void> startMonitoring() async {
    final repository = ref.read(heartRateRepositoryProvider);
    final result = await repository.startHeartRateMonitoring();

    result.fold(
      (failure) => state = false,
      (success) => state = success,
    );
  }

  /// Stop heart rate monitoring
  Future<void> stopMonitoring() async {
    final repository = ref.read(heartRateRepositoryProvider);
    final result = await repository.stopHeartRateMonitoring();

    result.fold(
      (failure) => state = false,
      (success) =>
          state = !success, // If success is true, we've stopped monitoring
    );
  }
}
