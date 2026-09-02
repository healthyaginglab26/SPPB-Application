import 'package:flutter_test/flutter_test.dart';
import 'package:sppb_app/services/scoring_service.dart';

void main() {
  group('balanceScore', () {
    test('fails side-by-side -> 0', () {
      expect(ScoringService.balanceScore(sideBySideSeconds: 9.9), 0);
    });

    test('passes side-by-side, fails semi-tandem -> 1', () {
      expect(
        ScoringService.balanceScore(
          sideBySideSeconds: 10,
          semiTandemSeconds: 4.2,
        ),
        1,
      );
    });

    test('semi-tandem attempted but null (edge case) treated as 0 -> 1', () {
      expect(ScoringService.balanceScore(sideBySideSeconds: 10), 1);
    });

    test('passes semi-tandem, tandem < 3s -> 2', () {
      expect(
        ScoringService.balanceScore(
          sideBySideSeconds: 10,
          semiTandemSeconds: 10,
          tandemSeconds: 1.5,
        ),
        2,
      );
    });

    test('tandem 3-9.99s -> 3', () {
      expect(
        ScoringService.balanceScore(
          sideBySideSeconds: 10,
          semiTandemSeconds: 10,
          tandemSeconds: 5.0,
        ),
        3,
      );
    });

    test('tandem >= 10s -> 4', () {
      expect(
        ScoringService.balanceScore(
          sideBySideSeconds: 10,
          semiTandemSeconds: 10,
          tandemSeconds: 10,
        ),
        4,
      );
    });
  });

  group('gaitScore', () {
    test('unable -> 0', () {
      expect(ScoringService.gaitScore(null), 0);
    });
    test('slow (>8.70s) -> 1', () {
      expect(ScoringService.gaitScore(9.0), 1);
    });
    test('6.21-8.70s -> 2', () {
      expect(ScoringService.gaitScore(7.0), 2);
    });
    test('4.82-6.20s -> 3', () {
      expect(ScoringService.gaitScore(5.5), 3);
    });
    test('<=4.81s -> 4', () {
      expect(ScoringService.gaitScore(4.0), 4);
    });

    test('bestGaitTime picks the faster (lower) trial', () {
      expect(ScoringService.bestGaitTime([6.5, 5.9]), 5.9);
      expect(ScoringService.bestGaitTime([null, 5.9]), 5.9);
      expect(ScoringService.bestGaitTime([null, null]), null);
    });
  });

  group('chairStandScore', () {
    test('unable to do single stand -> 0', () {
      expect(
        ScoringService.chairStandScore(
          singleStandSuccessful: false,
          fiveStandTimeSeconds: 10,
          fiveStandCompleted: true,
        ),
        0,
      );
    });

    test('did not complete all 5 -> 0', () {
      expect(
        ScoringService.chairStandScore(
          singleStandSuccessful: true,
          fiveStandTimeSeconds: 30,
          fiveStandCompleted: false,
        ),
        0,
      );
    });

    test('took 60s or more -> 0', () {
      expect(
        ScoringService.chairStandScore(
          singleStandSuccessful: true,
          fiveStandTimeSeconds: 60,
          fiveStandCompleted: true,
        ),
        0,
      );
    });

    test('<=11.19s -> 4', () {
      expect(
        ScoringService.chairStandScore(
          singleStandSuccessful: true,
          fiveStandTimeSeconds: 10,
          fiveStandCompleted: true,
        ),
        4,
      );
    });

    test('11.20-13.69s -> 3', () {
      expect(
        ScoringService.chairStandScore(
          singleStandSuccessful: true,
          fiveStandTimeSeconds: 12,
          fiveStandCompleted: true,
        ),
        3,
      );
    });

    test('13.70-16.69s -> 2', () {
      expect(
        ScoringService.chairStandScore(
          singleStandSuccessful: true,
          fiveStandTimeSeconds: 15,
          fiveStandCompleted: true,
        ),
        2,
      );
    });

    test('16.70-59.99s -> 1', () {
      expect(
        ScoringService.chairStandScore(
          singleStandSuccessful: true,
          fiveStandTimeSeconds: 20,
          fiveStandCompleted: true,
        ),
        1,
      );
    });
  });

  test('totalScore sums the three sub-scores', () {
    expect(ScoringService.totalScore(balance: 4, gait: 3, chairStand: 2), 9);
  });
}
