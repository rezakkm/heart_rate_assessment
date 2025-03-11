import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/heart_rate_entity.dart';

/// Widget to display the heart rate data
class HeartRateDisplay extends ConsumerWidget {
  final AsyncValue<Either<Failure, HeartRateEntity>> heartRateStream;

  const HeartRateDisplay({
    Key? key,
    required this.heartRateStream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return heartRateStream.when(
      data: (eitherData) {
        return eitherData.fold(
          (failure) => _buildErrorWidget(failure),
          (heartRateData) => _buildHeartRateWidget(heartRateData),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => _buildErrorWidget(
        UnexpectedFailure(error.toString()),
      ),
    );
  }

  Widget _buildHeartRateWidget(HeartRateEntity heartRateData) {
    final formattedTime = _formatTime(heartRateData.timestamp);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Current Heart Rate',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite,
              color: Colors.red,
              size: 40,
            ),
            const SizedBox(width: 10),
            Text(
              '${heartRateData.heartRate}',
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              ' BPM',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Last updated: $formattedTime',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(Failure failure) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 60,
        ),
        const SizedBox(height: 10),
        Text(
          'Error: ${failure.message}',
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    final seconds = time.second.toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
