import 'not_performed_reason.dart';

// The chair stand has a safety check stage, followed by a timed trial of five stands
class ChairStandResult {
  final bool singleStandAttempted;
  final bool? singleStandSuccessful;
  final NotPerformedReason? singleStandNotPerformedReason;

  final bool fiveStandAttempted;
  final double? fiveStandTimeSeconds;
  final bool fiveStandCompleted;
  final NotPerformedReason? fiveStandNotPerformedReason;

  const ChairStandResult({
    this.singleStandAttempted = false,
    this.singleStandSuccessful,
    this.singleStandNotPerformedReason,
    this.fiveStandAttempted = false,
    this.fiveStandTimeSeconds,
    this.fiveStandCompleted = false,
    this.fiveStandNotPerformedReason,
  });

  ChairStandResult copyWith({
    bool? singleStandAttempted,
    bool? singleStandSuccessful,
    NotPerformedReason? singleStandNotPerformedReason,
    bool? fiveStandAttempted,
    double? fiveStandTimeSeconds,
    bool? fiveStandCompleted,
    NotPerformedReason? fiveStandNotPerformedReason,
  }) {
    return ChairStandResult(
      singleStandAttempted: singleStandAttempted ?? this.singleStandAttempted,
      singleStandSuccessful:
          singleStandSuccessful ?? this.singleStandSuccessful,
      singleStandNotPerformedReason:
          singleStandNotPerformedReason ?? this.singleStandNotPerformedReason,
      fiveStandAttempted: fiveStandAttempted ?? this.fiveStandAttempted,
      fiveStandTimeSeconds: fiveStandTimeSeconds ?? this.fiveStandTimeSeconds,
      fiveStandCompleted: fiveStandCompleted ?? this.fiveStandCompleted,
      fiveStandNotPerformedReason:
          fiveStandNotPerformedReason ?? this.fiveStandNotPerformedReason,
    );
  }

  Map<String, dynamic> toRow(String assessmentId) => {
        'assessment_id': assessmentId,
        'single_stand_attempted': singleStandAttempted,
        'single_stand_successful': singleStandSuccessful,
        'single_stand_not_performed_reason':
            singleStandNotPerformedReason?.dbValue,
        'five_stand_attempted': fiveStandAttempted,
        'five_stand_time_seconds': fiveStandTimeSeconds,
        'five_stand_completed': fiveStandCompleted,
        'five_stand_not_performed_reason':
            fiveStandNotPerformedReason?.dbValue,
      };
}
