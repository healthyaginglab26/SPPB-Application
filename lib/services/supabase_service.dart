import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../config/supabase_config.dart';
import '../models/assessment.dart';
import '../models/balance_trial.dart';
import '../models/chair_stand_result.dart';
import '../models/gait_trial.dart';

const _uuid = Uuid();

// All Supabase reads/writes for the app are here
// Writes go straight toSupabase (no local offline cache) 
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  }

  // Inserts the assessment header row and returns its id.
  static Future<String> createAssessment(Assessment assessment) async {
    final id = _uuid.v4();
    await _client.from('assessments').insert({
      'id': id,
      'assessment_date': assessment.date.toIso8601String(),
      'assessment_type': assessment.assessmentType?.dbValue,
      'patient_first_name': assessment.patientFirstName.trim(),
      'patient_last_name': assessment.patientLastName.trim(),
      'physician_first_name': assessment.physicianFirstName.trim().isEmpty
          ? null
          : assessment.physicianFirstName.trim(),
      'physician_last_name': assessment.physicianLastName.trim().isEmpty
          ? null
          : assessment.physicianLastName.trim(),
      'test_location': assessment.testLocation?.dbValue,
      'test_administrator_1': assessment.testAdministrator1.trim(),
      'test_administrator_2': assessment.testAdministrator2.trim().isEmpty
          ? null
          : assessment.testAdministrator2.trim(),
      'status': 'in_progress',
    });
    return id;
  }

  static Future<void> saveBalanceTrials(
    String assessmentId,
    List<BalanceTrial> trials,
  ) async {
    if (trials.isEmpty) return;
    await _client
        .from('balance_trials')
        .upsert(
          trials.map((t) => t.toRow(assessmentId)).toList(),
          onConflict: 'assessment_id,stance',
        );
  }

  static Future<void> saveGaitTrials(
    String assessmentId,
    List<GaitTrial> trials,
  ) async {
    if (trials.isEmpty) return;
    await _client
        .from('gait_trials')
        .upsert(
          trials.map((t) => t.toRow(assessmentId)).toList(),
          onConflict: 'assessment_id,trial_number',
        );
  }

  static Future<void> saveChairStand(
    String assessmentId,
    ChairStandResult result,
  ) async {
    await _client
        .from('chair_stand_trials')
        .upsert(result.toRow(assessmentId), onConflict: 'assessment_id');
  }

  // Final call once all three components are complete
  static Future<void> completeAssessment({
    required String assessmentId,
    required int balanceScore,
    required int gaitScore,
    required int chairStandScore,
    required int totalScore,
  }) async {
    await _client.from('assessments').update({
      'balance_score': balanceScore,
      'gait_score': gaitScore,
      'chair_stand_score': chairStandScore,
      'total_score': totalScore,
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', assessmentId);
  }
}
