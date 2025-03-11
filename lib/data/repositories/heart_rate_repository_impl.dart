import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import '../../core/error/failures.dart';
import '../../domain/entities/heart_rate_entity.dart';
import '../../domain/repositories/heart_rate_repository.dart';
import '../datasources/heart_rate_data_source.dart';

/// Implementation of HeartRateRepository
class HeartRateRepositoryImpl implements HeartRateRepository {
  final HeartRateDataSource _dataSource;

  HeartRateRepositoryImpl(this._dataSource) {
    developer.log('HeartRateRepositoryImpl initialized',
        name: 'HeartRateRepository');
  }

  @override
  Stream<Either<Failure, HeartRateEntity>> getHeartRateStream() {
    developer.log('Getting heart rate stream from repository',
        name: 'HeartRateRepository');

    // Transform the data source stream to handle errors and map to the domain entity
    return _dataSource
        .getHeartRateStream()
        .map<Either<Failure, HeartRateEntity>>((data) {
      try {
        developer.log('Transforming data to entity: $data',
            name: 'HeartRateRepository');
        final heartRateEntity = HeartRateEntity.fromMap(data);
        developer.log('Created entity: ${heartRateEntity.heartRate} BPM',
            name: 'HeartRateRepository');
        return Right(heartRateEntity);
      } on Exception catch (e) {
        developer.log('Failed to parse heart rate data',
            name: 'HeartRateRepository', error: e);
        return Left(HeartRateFailure(
            'Failed to parse heart rate data: ${e.toString()}'));
      }
    }).handleError((error) {
      developer.log('Stream error', name: 'HeartRateRepository', error: error);
      if (error is PlatformException) {
        return Left(
            PlatformFailure(error.message ?? 'Platform error occurred'));
      }
      return Left(UnexpectedFailure(error.toString()));
    });
  }

  @override
  Future<Either<Failure, bool>> startHeartRateMonitoring() async {
    developer.log('Starting heart rate monitoring from repository',
        name: 'HeartRateRepository');
    try {
      final result = await _dataSource.startHeartRateMonitoring();
      developer.log('Heart rate monitoring started: $result',
          name: 'HeartRateRepository');
      return Right(result);
    } on PlatformException catch (e) {
      developer.log('Platform error starting monitoring',
          name: 'HeartRateRepository', error: e);
      return Left(PlatformFailure(
          e.message ?? 'Failed to start heart rate monitoring'));
    } catch (e) {
      developer.log('Unexpected error starting monitoring',
          name: 'HeartRateRepository', error: e);
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> stopHeartRateMonitoring() async {
    developer.log('Stopping heart rate monitoring from repository',
        name: 'HeartRateRepository');
    try {
      final result = await _dataSource.stopHeartRateMonitoring();
      developer.log('Heart rate monitoring stopped: $result',
          name: 'HeartRateRepository');
      return Right(result);
    } on PlatformException catch (e) {
      developer.log('Platform error stopping monitoring',
          name: 'HeartRateRepository', error: e);
      return Left(
          PlatformFailure(e.message ?? 'Failed to stop heart rate monitoring'));
    } catch (e) {
      developer.log('Unexpected error stopping monitoring',
          name: 'HeartRateRepository', error: e);
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
