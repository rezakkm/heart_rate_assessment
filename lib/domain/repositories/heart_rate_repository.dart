import 'package:dartz/dartz.dart';
import '../entities/heart_rate_entity.dart';
import '../../core/error/failures.dart';

/// Interface for the heart rate repository
abstract class HeartRateRepository {
  /// Stream of heart rate data
  Stream<Either<Failure, HeartRateEntity>> getHeartRateStream();

  /// Start monitoring heart rate
  Future<Either<Failure, bool>> startHeartRateMonitoring();

  /// Stop monitoring heart rate
  Future<Either<Failure, bool>> stopHeartRateMonitoring();
}
