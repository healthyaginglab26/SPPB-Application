import 'package:flutter/foundation.dart';

import '../models/assessment.dart';
import '../models/balance_trial.dart';
import '../models/chair_stand_result.dart';
import '../models/gait_trial.dart';
import '../models/not_performed_reason.dart';
import '../services/scoring_service.dart';
import '../services/supabase_service.dart';

/// Holds all state for the SPPB assessment currently being administered:
class AssessmentSession extends ChangeNotifier {
  AssessmentSession({this.gaitOnly = false});

  Assessment assessment = Assessment();
  String? _assessmentId;

  /// True when this session was started from the Home screen's
  /// "Go to Gait Speed Test Only" entry point: balance and chair stand
  /// are never administered and get saved as "not applicable" instead.
  final bool gaitOnly;

  final Map<BalanceStance, BalanceTrial> _balanceTrials = {};
  final List<GaitTrial> _gaitTrials = [];
  ChairStandResult chairStand = const ChairStandResult();

  // Course length chosen on the gait course-length prompt (3.0 or 4.0),
  double? gaitDistanceMeters;
  GaitStartType gaitStartType = GaitStartType.standing;

  String? get assessmentId => _assessmentId;

  BalanceTrial? trialFor(BalanceStance stance) => _balanceTrials[stance];

  List<GaitTrial> get gaitTrials => List.unmodifiable(_gaitTrials);

  void setGaitDistance(double meters) {
    gaitDistanceMeters = meters;
    notifyListeners();
  }

  void setGaitStartType(GaitStartType startType) {
    gaitStartType = startType;
    notifyListeners();
  }

  // Scoring (Computed live to update score)

  int get balanceScore => ScoringService.balanceScore(
        sideBySideSeconds:
            _balanceTrials[BalanceStance.sideBySide]?.scorableSeconds ?? 0,
        semiTandemSeconds: _balanceTrials[BalanceStance.semiTandem]
            ?.scorableSeconds,
        tandemSeconds: _balanceTrials[BalanceStance.tandem]?.scorableSeconds,
      );

  double? get bestGaitTime => ScoringService.bestGaitTime(
        _gaitTrials.map((t) => t.timeSeconds),
      );

  int get gaitScore => ScoringService.gaitScore(
        bestGaitTime,
        distanceMeters: gaitDistanceMeters ?? 4.0,
      );

  int get chairStandScore => ScoringService.chairStandScore(
        singleStandSuccessful: chairStand.singleStandSuccessful ?? false,
        fiveStandTimeSeconds: chairStand.fiveStandTimeSeconds,
        fiveStandCompleted: chairStand.fiveStandCompleted,
      );

  int get totalScore => ScoringService.totalScore(
        balance: balanceScore,
        gait: gaitScore,
        chairStand: chairStandScore,
      );

  bool get shouldAttemptSemiTandem =>
      (_balanceTrials[BalanceStance.sideBySide]?.scorableSeconds ?? 0) >= 10;

  // Whether the tandem stance should be attempted,
  bool get shouldAttemptTandem =>
      (_balanceTrials[BalanceStance.semiTandem]?.scorableSeconds ?? 0) >= 10;


  void recordBalanceTrial(BalanceTrial trial) {
    _balanceTrials[trial.stance] = trial;
    notifyListeners();
  }

  void recordGaitTrial(GaitTrial trial) {
    _gaitTrials.removeWhere((t) => t.trialNumber == trial.trialNumber);
    _gaitTrials.add(trial);
    _gaitTrials.sort((a, b) => a.trialNumber.compareTo(b.trialNumber));
    notifyListeners();
  }

  void updateChairStand(ChairStandResult Function(ChairStandResult) update) {
    chairStand = update(chairStand);
    notifyListeners();
  }

  /// Marks Balance and Chair Stand as not applicable and saves that to
  /// Supabase, for a gait-speed-only assessment. Safe to call more than
  /// once (e.g. if the administrator backs out and re-enters).
  Future<void> skipNonGaitComponents() async {
    for (final stance in BalanceStance.values) {
      _balanceTrials[stance] = BalanceTrial(
        stance: stance,
        attempted: false,
        notPerformedReason: NotPerformedReason.notApplicable,
      );
    }
    chairStand = chairStand.copyWith(
      singleStandAttempted: false,
      singleStandNotPerformedReason: NotPerformedReason.notApplicable,
      fiveStandAttempted: false,
      fiveStandNotPerformedReason: NotPerformedReason.notApplicable,
    );
    notifyListeners();
    await saveBalanceTrials();
    await saveChairStand();
  }

  // Creates the assessment header row in Supabase. Called once, right after the "New Assessment" form is submitted, so an id exists for every subsequent trial insert.
  Future<void> createAssessmentRecord() async {
    _assessmentId = await SupabaseService.createAssessment(assessment);
    notifyListeners();
  }

  Future<void> saveBalanceTrials() async {
    final id = _assessmentId;
    if (id == null) return;
    await SupabaseService.saveBalanceTrials(id, _balanceTrials.values.toList());
  }

  Future<void> saveGaitTrials() async {
    final id = _assessmentId;
    if (id == null) return;
    await SupabaseService.saveGaitTrials(id, _gaitTrials);
  }

  Future<void> saveChairStand() async {
    final id = _assessmentId;
    if (id == null) return;
    await SupabaseService.saveChairStand(id, chairStand);
  }

  // Writes the final computed scores and marks the assessment complete.
  Future<void> finalizeAssessment() async {
    final id = _assessmentId;
    if (id == null) return;
    await SupabaseService.completeAssessment(
      assessmentId: id,
      balanceScore: balanceScore,
      gaitScore: gaitScore,
      chairStandScore: chairStandScore,
      totalScore: totalScore,
    );
  }
}
