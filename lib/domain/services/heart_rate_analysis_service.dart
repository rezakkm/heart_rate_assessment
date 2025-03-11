import 'package:flutter/material.dart';

/// Heart rate category based on BPM value
enum HeartRateCategory { low, normal, elevated, high, critical }

/// Provides analysis of heart rate values
class HeartRateAnalysisService {
  // Heart rate ranges
  static const int lowHeartRateUpperLimit = 59;
  static const int normalHeartRateLowerLimit = 60;
  static const int normalHeartRateUpperLimit = 100;
  static const int elevatedHeartRateLowerLimit = 101;
  static const int elevatedHeartRateUpperLimit = 130;
  static const int highHeartRateLowerLimit = 131;
  static const int highHeartRateUpperLimit = 180;
  static const int criticalHeartRateThreshold = 181;

  /// Categorize a heart rate value
  static HeartRateCategory categorizeHeartRate(int heartRate) {
    if (heartRate <= lowHeartRateUpperLimit) {
      return HeartRateCategory.low;
    } else if (heartRate <= normalHeartRateUpperLimit) {
      return HeartRateCategory.normal;
    } else if (heartRate <= elevatedHeartRateUpperLimit) {
      return HeartRateCategory.elevated;
    } else if (heartRate <= highHeartRateUpperLimit) {
      return HeartRateCategory.high;
    } else {
      return HeartRateCategory.critical;
    }
  }

  /// Get a descriptive analysis of the heart rate
  static String getHeartRateAnalysis(int heartRate) {
    final category = categorizeHeartRate(heartRate);

    switch (category) {
      case HeartRateCategory.low:
        return 'Your heart rate is low. This might indicate rest state or bradycardia if persistent.';
      case HeartRateCategory.normal:
        return 'Your heart rate is within normal range. Indicates healthy cardiovascular function.';
      case HeartRateCategory.elevated:
        return 'Your heart rate is slightly elevated. This is common during light activity or mild stress.';
      case HeartRateCategory.high:
        return 'Your heart rate is high. This occurs during exercise, stress, or could indicate tachycardia.';
      case HeartRateCategory.critical:
        return 'Your heart rate is critically high! This can be dangerous and may require medical attention if not during intense exercise.';
    }
  }

  /// Get a short one-word status for the heart rate
  static String getHeartRateStatus(int heartRate) {
    final category = categorizeHeartRate(heartRate);

    switch (category) {
      case HeartRateCategory.low:
        return 'LOW';
      case HeartRateCategory.normal:
        return 'NORMAL';
      case HeartRateCategory.elevated:
        return 'ELEVATED';
      case HeartRateCategory.high:
        return 'HIGH';
      case HeartRateCategory.critical:
        return 'CRITICAL';
    }
  }

  /// Get the color associated with the heart rate category
  static Color getHeartRateColor(int heartRate) {
    final category = categorizeHeartRate(heartRate);

    switch (category) {
      case HeartRateCategory.low:
        return Colors.blue;
      case HeartRateCategory.normal:
        return Colors.green;
      case HeartRateCategory.elevated:
        return Colors.orange;
      case HeartRateCategory.high:
        return Colors.deepOrange;
      case HeartRateCategory.critical:
        return Colors.red;
    }
  }

  /// Get a color gradient for heart rate visualization
  static List<Color> getHeartRateGradient(int heartRate) {
    final baseColor = getHeartRateColor(heartRate);

    return [
      baseColor.withOpacity(0.7),
      baseColor,
      baseColor.withOpacity(0.8),
    ];
  }

  /// Get the animation speed for heart beat visualization
  static Duration getHeartBeatAnimationDuration(int heartRate) {
    // Convert BPM to milliseconds per beat
    final millisPerBeat = 60000 ~/ heartRate;
    return Duration(milliseconds: millisPerBeat);
  }
}
