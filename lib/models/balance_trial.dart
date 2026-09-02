import 'not_performed_reason.dart';

enum BalanceStance {
  sideBySide,
  semiTandem,
  tandem;

  String get label {
    switch (this) {
      case BalanceStance.sideBySide:
        return 'Side-by-Side Stance';
      case BalanceStance.semiTandem:
        return 'Semi-Tandem Stance';
      case BalanceStance.tandem:
        return 'Tandem Stance';
    }
  }

  String get dbValue => name;
}


class BalanceTrial {
  final BalanceStance stance;
  final bool attempted;
  final double? heldSeconds;
  final NotPerformedReason? notPerformedReason;

  const BalanceTrial({
    required this.stance,
    required this.attempted,
    this.heldSeconds,
    this.notPerformedReason,
  });

  //Seconds held, treat "not attempted" as 0
  double get scorableSeconds => attempted ? (heldSeconds ?? 0) : 0;

  Map<String, dynamic> toRow(String assessmentId) => {
        'assessment_id': assessmentId,
        'stance': stance.dbValue,
        'attempted': attempted,
        'held_seconds': heldSeconds,
        'not_performed_reason': notPerformedReason?.dbValue,
      };
}
