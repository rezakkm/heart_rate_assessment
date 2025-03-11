import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/heart_rate_entity.dart';
import '../../domain/repositories/heart_rate_repository.dart';
import '../datasources/heart_rate_data_source.dart';

/// Implementation of HeartRateRepository
class HeartRateRepositoryImpl implements HeartRateRepository {
  final HeartRateDataSource _dataSource;

  HeartRateRepositoryImpl(this._dataSource);

  @override
  Stream<Either<Failure, HeartRateEntity>> getHeartRateStream() {
    return _dataSource
        .getHeartRateStream()
        .map<Either<Failure, HeartRateEntity>>((data) {
      try {
        final heartRateEntity = HeartRateEntity.fromMap(data);
        return Right(heartRateEntity);
      } on Exception catch (e) {
        return Left(HeartRateFailure(
            'Failed to parse heart rate data: ${e.toString()}'));
      }
    }).handleError((error) {
      if (error is PlatformException) {
        return Left(
            PlatformFailure(error.message ?? 'Platform error occurred'));
      }
      return Left(UnexpectedFailure(error.toString()));
    });
  }

  @override
  Future<Either<Failure, bool>> startHeartRateMonitoring() async {
    try {
      final result = await _dataSource.startHeartRateMonitoring();
      return Right(result);
    } on PlatformException catch (e) {
      return Left(PlatformFailure(
          e.message ?? 'Failed to start heart rate monitoring'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> stopHeartRateMonitoring() async {
    try {
      final result = await _dataSource.stopHeartRateMonitoring();
      return Right(result);
    } on PlatformException catch (e) {
      return Left(
          PlatformFailure(e.message ?? 'Failed to stop heart rate monitoring'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
