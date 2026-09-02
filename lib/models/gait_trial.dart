import 'not_performed_reason.dart';

// One 4-meter or 3-meter usual-pace walk trial. 
// There are two trials, scored on whichever is faster.
class GaitTrial {
  final int trialNumber; // 1 or 2
  final double distanceMeters;
  final bool attempted;
  final double? timeSeconds;
  final NotPerformedReason? notPerformedReason;

  const GaitTrial({
    required this.trialNumber,
    this.distanceMeters = 4.0,
    required this.attempted,
    this.timeSeconds,
    this.notPerformedReason,
  });

  Map<String, dynamic> toRow(String assessmentId) => {
        'assessment_id': assessmentId,
        'trial_number': trialNumber,
        'distance_meters': distanceMeters,
        'attempted': attempted,
        'time_seconds': timeSeconds,
        'not_performed_reason': notPerformedReason?.dbValue,
      };
}
