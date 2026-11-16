import 'not_performed_reason.dart';

/// How the participant was already moving when timing started.
enum GaitStartType {
  /// Standard SPPB protocol: participant is standing still at the start
  /// line before timing begins.
  standing,

  /// Participant has a few steps of run-up before crossing the start
  /// line, so timing begins already in motion.
  moving;

  String get label {
    switch (this) {
      case GaitStartType.standing:
        return 'Standing Start';
      case GaitStartType.moving:
        return 'Moving Start';
    }
  }

  String get dbValue => name;
}

// One usual-pace walk trial (3m or 4m course). Up to three trials may be
// recorded; scoring uses whichever completed trial was fastest.
class GaitTrial {
  final int trialNumber; // 1, 2, or optionally 3
  final double distanceMeters;
  final GaitStartType startType;
  final bool attempted;
  final double? timeSeconds;
  final NotPerformedReason? notPerformedReason;

  const GaitTrial({
    required this.trialNumber,
    this.distanceMeters = 4.0,
    this.startType = GaitStartType.standing,
    required this.attempted,
    this.timeSeconds,
    this.notPerformedReason,
  });

  Map<String, dynamic> toRow(String assessmentId) => {
        'assessment_id': assessmentId,
        'trial_number': trialNumber,
        'distance_meters': distanceMeters,
        'start_type': startType.dbValue,
        'attempted': attempted,
        'time_seconds': timeSeconds,
        'not_performed_reason': notPerformedReason?.dbValue,
      };
}
