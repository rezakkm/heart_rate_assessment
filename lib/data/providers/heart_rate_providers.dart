import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/heart_rate_entity.dart';
import '../../domain/repositories/heart_rate_repository.dart';
import '../datasources/heart_rate_data_source.dart';
import '../datasources/local/local_heart_rate_data_source.dart';
import '../repositories/heart_rate_repository_impl.dart';

// Data source providers
final heartRateDataSourceProvider = Provider<HeartRateDataSource>((ref) {
  return HeartRateDataSourceImpl();
});

// Local data source provider for testing or development purposes
final localHeartRateDataSourceProvider = Provider<HeartRateDataSource>((ref) {
  return LocalHeartRateDataSource(
    // Configure with desired parameters
    updateInterval: const Duration(seconds: 1),
    minRate: 60,
    maxRate: 100,
    simulateAbnormalReadings: true,
    abnormalReadingProbability: 0.3,
  );
});

// Repository provider
final heartRateRepositoryProvider = Provider<HeartRateRepository>((ref) {
  // Use the platform data source by default
  return HeartRateRepositoryImpl(ref.watch(heartRateDataSourceProvider));
});

// Local repository provider for testing or development
final localHeartRateRepositoryProvider = Provider<HeartRateRepository>((ref) {
  return HeartRateRepositoryImpl(ref.watch(localHeartRateDataSourceProvider));
});

// Heart rate stream provider
final heartRateStreamProvider =
    StreamProvider<Either<Failure, HeartRateEntity>>((ref) {
  final repository = ref.watch(heartRateRepositoryProvider);
  return repository.getHeartRateStream();
});

// Local heart rate stream provider for testing or development
final localHeartRateStreamProvider =
    StreamProvider<Either<Failure, HeartRateEntity>>((ref) {
  final repository = ref.watch(localHeartRateRepositoryProvider);
  return repository.getHeartRateStream();
});

// Use local data source flag
final useLocalDataSourceProvider = StateProvider<bool>((ref) => false);

// Dynamic heart rate stream provider that switches between native and local based on the flag
final dynamicHeartRateStreamProvider =
    StreamProvider<Either<Failure, HeartRateEntity>>((ref) {
  final useLocalDataSource = ref.watch(useLocalDataSourceProvider);

  if (useLocalDataSource) {
    return ref.watch(localHeartRateStreamProvider.stream);
  } else {
    return ref.watch(heartRateStreamProvider.stream);
  }
});
