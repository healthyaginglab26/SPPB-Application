//List of not completed reasons
enum NotPerformedReason {
  triedButUnable,
  notAttemptedFeltUnsafe,
  unableToFollowInstruction,
  administratorStoppedTest,
  refused;

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
    }
  }

  String get dbValue => name;
}
