import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart' hide State;
import 'dart:developer' as developer;

import '../../core/error/failures.dart';
import '../../domain/entities/heart_rate_entity.dart';
import '../../domain/services/heart_rate_analysis_service.dart';

/// Widget to display the heart rate data with analysis and visual indicators
class HeartRateDisplay extends ConsumerWidget {
  final AsyncValue<Either<Failure, HeartRateEntity>> heartRateStream;

  const HeartRateDisplay({
    Key? key,
    required this.heartRateStream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log(
        'Building HeartRateDisplay, state: ${heartRateStream.valueOrNull}',
        name: 'HeartRateDisplay');

    return heartRateStream.when(
      data: (eitherData) {
        developer.log('HeartRateDisplay received data: $eitherData',
            name: 'HeartRateDisplay');
        return eitherData.fold(
          (failure) {
            developer.log('HeartRateDisplay failure: ${failure.message}',
                name: 'HeartRateDisplay');
            return _buildErrorWidget(failure);
          },
          (heartRateData) => _buildHeartRateWidget(heartRateData),
        );
      },
      loading: () {
        developer.log('HeartRateDisplay is in loading state',
            name: 'HeartRateDisplay');
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Waiting for heart rate data...'),
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        developer.log('HeartRateDisplay error: $error',
            name: 'HeartRateDisplay', error: error, stackTrace: stackTrace);
        return _buildErrorWidget(
          UnexpectedFailure('Stream error: ${error.toString()}'),
        );
      },
    );
  }

  Widget _buildHeartRateWidget(HeartRateEntity heartRateData) {
    final formattedTime = _formatTime(heartRateData.timestamp);
    final heartRate = heartRateData.heartRate;
    final heartRateColor =
        HeartRateAnalysisService.getHeartRateColor(heartRate);
    final heartRateStatus =
        HeartRateAnalysisService.getHeartRateStatus(heartRate);
    final heartRateAnalysis =
        HeartRateAnalysisService.getHeartRateAnalysis(heartRate);
    final animationDuration =
        HeartRateAnalysisService.getHeartBeatAnimationDuration(heartRate);

    developer.log(
        'Building heart rate widget with rate: $heartRate, status: $heartRateStatus, time: $formattedTime',
        name: 'HeartRateDisplay');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: heartRateColor.withOpacity(0.5), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current Heart Rate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            _HeartBeatIndicator(
              color: heartRateColor,
              animationDuration: animationDuration,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$heartRate',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: heartRateColor,
                  ),
                ),
                Text(
                  ' BPM',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: heartRateColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                heartRateStatus,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: heartRateColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              heartRateAnalysis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
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
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Failure failure) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.withOpacity(0.5), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // This is a simple way to trigger a rebuild
                developer.log('Retry button pressed', name: 'HeartRateDisplay');
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    final seconds = time.second.toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

/// Animated heart beat indicator that pulses at the rate of the heart beat
class _HeartBeatIndicator extends StatefulWidget {
  final Color color;
  final Duration animationDuration;

  const _HeartBeatIndicator({
    required this.color,
    required this.animationDuration,
  });

  @override
  State<_HeartBeatIndicator> createState() => _HeartBeatIndicatorState();
}

class _HeartBeatIndicatorState extends State<_HeartBeatIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.5)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 55,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void didUpdateWidget(_HeartBeatIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationDuration != widget.animationDuration) {
      _controller.duration = widget.animationDuration;
      if (_controller.isAnimating) {
        _controller.reset();
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Icon(
            Icons.favorite,
            color: widget.color,
            size: 60,
          ),
        );
      },
    );
  }
}
