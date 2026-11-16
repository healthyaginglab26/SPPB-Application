//List of not completed reasons
enum NotPerformedReason {
  triedButUnable,
  notAttemptedFeltUnsafe,
  unableToFollowInstruction,
  administratorStoppedTest,
  refused,
  // Used when a component is skipped on purpose (e.g. a gait-speed-only
  // assessment), not because the participant couldn't do it.
  notApplicable;

  String get label {
    switch (this) {
      case NotPerformedReason.triedButUnable:
        return 'Tried but unable';
      case NotPerformedReason.notAttemptedFeltUnsafe:
        return 'Not attempted, felt unsafe';
      case NotPerformedReason.unableToFollowInstruction:
        return 'Unable to follow instruction';
      case NotPerformedReason.administratorStoppedTest:
        return 'Administrator stopped test';
      case NotPerformedReason.refused:
        return 'Refused';
      case NotPerformedReason.notApplicable:
        return 'Not applicable (component skipped)';
    }
  }

  String get dbValue => name;
}
