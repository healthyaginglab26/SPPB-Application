/// Pure scoring functionse.
class ScoringService {
  ScoringService._();

  // Balance sub-score (0-4).
  static int balanceScore({
    required double sideBySideSeconds,
    double? semiTandemSeconds,
    double? tandemSeconds,
  }) {
    if (sideBySideSeconds < 10) // 0 if unable or not attempted
      return 0; 

    final semiTandem = semiTandemSeconds ?? 0;
    if (semiTandem < 10) 
      return 1;

    final tandem = tandemSeconds ?? 0;
    if (tandem < 3) 
      return 2;
    if (tandem < 10) 
      return 3;
    return 4;
  }

  // Gait speed sub-score (0-4) from the faster of up to two trials
  static int gaitScore(double? bestTimeSeconds) {
    if (bestTimeSeconds == null) 
      return 0;
    if (bestTimeSeconds <= 4.81) 
      return 4;
    if (bestTimeSeconds <= 6.20) 
      return 3;
    if (bestTimeSeconds <= 8.70) 
      return 2;
    return 1;
  }

  // Returns the faster of the completed gait trial times, ornull if neither trial produced a time.
  static double? bestGaitTime(Iterable<double?> trialTimes) {
    final valid = trialTimes.whereType<double>().toList();
    if (valid.isEmpty) return null;
    valid.sort();
    return valid.first;
  }

  // Chair stand sub-score (0-4).
  static int chairStandScore({
    required bool singleStandSuccessful,
    double? fiveStandTimeSeconds,
    required bool fiveStandCompleted,
  }) {
    if (!singleStandSuccessful) //0 if unssuccesful
      return 0;
    if (!fiveStandCompleted || fiveStandTimeSeconds == null) 
      return 0;
    if (fiveStandTimeSeconds >= 60) 
      return 0;
    if (fiveStandTimeSeconds <= 11.19) 
      return 4;
    if (fiveStandTimeSeconds <= 13.69) 
      return 3;
    if (fiveStandTimeSeconds <= 16.69) 
      return 2;
    return 1;
  }

  /// Total SPPB score, 0-12.
  static int totalScore({
    required int balance,
    required int gait,
    required int chairStand,
  }) =>
      balance + gait + chairStand;
}
