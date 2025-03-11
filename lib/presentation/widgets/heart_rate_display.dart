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
          (failure) => _buildErrorWidget(context, failure),
          (heartRateData) => _buildHeartRateWidget(context, heartRateData),
        );
      },
      loading: () {
        developer.log('HeartRateDisplay is in loading state',
            name: 'HeartRateDisplay');
        return _buildLoadingWidget(context);
      },
      error: (error, stackTrace) {
        developer.log('HeartRateDisplay error: $error',
            name: 'HeartRateDisplay', error: error, stackTrace: stackTrace);
        return _buildErrorWidget(
          context,
          UnexpectedFailure('Stream error: ${error.toString()}'),
        );
      },
    );
  }

  Widget _buildHeartRateWidget(
      BuildContext context, HeartRateEntity heartRateData) {
    final formattedTime = _formatTime(heartRateData.timestamp);
    final heartRate =
        heartRateData.heartRate <= 0 ? 60 : heartRateData.heartRate;
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
      elevation: 3,
      shadowColor: heartRateColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: heartRateColor.withOpacity(0.3), width: 1.5),
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned.fill(
            child: CustomPaint(
              painter: _HeartRateBackgroundPainter(
                color: heartRateColor.withOpacity(0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and heart icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Current Heart Rate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Heart beat animation
                _HeartBeatIndicator(
                  color: heartRateColor,
                  animationDuration: animationDuration,
                ),

                const SizedBox(height: 24),

                // Heart rate value
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$heartRate',
                      style: TextStyle(
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                        color: heartRateColor,
                      ),
                    ),
                    Text(
                      ' BPM',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Status indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: heartRateColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
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

                // Analysis text
                Text(
                  heartRateAnalysis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                // Last updated
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Last updated: $formattedTime',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Connecting to Device',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please wait while we establish a connection...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, Failure failure) {
    return Card(
      elevation: 3,
      shadowColor: Theme.of(context).colorScheme.error.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 70,
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Retry logic could go here
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
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

// A custom painter for drawing a subtle wave pattern background
class _HeartRateBackgroundPainter extends CustomPainter {
  final Color color;

  _HeartRateBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create a subtle wave pattern
    path.moveTo(0, size.height * 0.7);

    for (int i = 0; i < 3; i++) {
      // Draw waves with varying heights
      path.quadraticBezierTo(
        size.width * (0.1 + i * 0.3),
        size.height * (0.7 + (i % 2 == 0 ? 0.1 : -0.1)),
        size.width * (0.2 + i * 0.3),
        size.height * 0.7,
      );
    }

    path.lineTo(size.width, size.height * 0.7);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HeartRateBackgroundPainter oldDelegate) =>
      oldDelegate.color != color;
}
