import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;

  const Failure([this.message = '']);

  @override
  List<Object> get props => [message];
}

/// Failure that occurs when there's an issue with the platform channel
class PlatformFailure extends Failure {
  const PlatformFailure([String message = 'Platform error occurred'])
      : super(message);
}

/// Failure that occurs when there's an issue with the heart rate monitoring
class HeartRateFailure extends Failure {
  const HeartRateFailure([String message = 'Heart rate monitoring error'])
      : super(message);
}

/// Failure that occurs when there's an unexpected error
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([String message = 'Unexpected error occurred'])
      : super(message);
}
