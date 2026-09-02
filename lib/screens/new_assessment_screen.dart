import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/assessment.dart';
import '../state/assessment_session.dart';
import '../widgets/sppb_scaffold.dart';
import 'sppb_intro_screen.dart';

/// The patient / administrator header form, matching the fields in the
/// reference app's "New Assessment" screen: date, time, assessment
/// type, patient & physician name, location, and up to two
/// administrators.
class NewAssessmentScreen extends StatefulWidget {
  const NewAssessmentScreen({super.key});

  @override
  State<NewAssessmentScreen> createState() => _NewAssessmentScreenState();
}

class _NewAssessmentScreenState extends State<NewAssessmentScreen> {
  final _patientFirstController = TextEditingController();
  final _patientLastController = TextEditingController();
  final _physicianFirstController = TextEditingController();
  final _physicianLastController = TextEditingController();
  final _admin1Controller = TextEditingController();
  final _admin2Controller = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _patientFirstController.dispose();
    _patientLastController.dispose();
    _physicianFirstController.dispose();
    _physicianLastController.dispose();
    _admin1Controller.dispose();
    _admin2Controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate(AssessmentSession session) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: session.assessment.date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        final current = session.assessment.date;
        session.assessment.date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          current.hour,
          current.minute,
        );
      });
    }
  }

  Future<void> _pickTime(AssessmentSession session) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(session.assessment.date),
    );
    if (picked != null && mounted) {
      setState(() {
        final current = session.assessment.date;
        session.assessment.date = DateTime(
          current.year,
          current.month,
          current.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _submit(AssessmentSession session) async {
    session.assessment.patientFirstName = _patientFirstController.text;
    session.assessment.patientLastName = _patientLastController.text;
    session.assessment.physicianFirstName = _physicianFirstController.text;
    session.assessment.physicianLastName = _physicianLastController.text;
    session.assessment.testAdministrator1 = _admin1Controller.text;
    session.assessment.testAdministrator2 = _admin2Controller.text;

    if (!session.assessment.isReadyForNext) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in assessment type, patient name, location, and '
            'at least one test administrator.',
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await session.createAssessmentRecord();
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: session,
            child: const SppbIntroScreen(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start assessment: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AssessmentSession>();
    final assessment = session.assessment;
    final dateFormat = DateFormat.yMMMd();
    final timeFormat = DateFormat.jm();

    return SppbScaffold(
      title: 'SPPB',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FieldRow(
              label: 'Date',
              child: Text(dateFormat.format(assessment.date)),
              onTap: () => _pickDate(session),
            ),
            _FieldRow(
              label: 'Time',
              child: Text(timeFormat.format(assessment.date)),
              onTap: () => _pickTime(session),
            ),
            _FieldRow(
              label: 'Assessment Type',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<AssessmentType>(
                  isExpanded: true,
                  hint: const Text('Choose type'),
                  value: assessment.assessmentType,
                  items: AssessmentType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => assessment.assessmentType = value),
                ),
              ),
            ),
            _FieldRow(
              label: 'Patient First Name',
              child: TextField(
                controller: _patientFirstController,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            _FieldRow(
              label: 'Patient Last Name',
              child: TextField(
                controller: _patientLastController,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            _FieldRow(
              label: 'Physician First Name',
              child: TextField(
                controller: _physicianFirstController,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            _FieldRow(
              label: 'Physician Last Name',
              child: TextField(
                controller: _physicianLastController,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            _FieldRow(
              label: 'Test Location',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TestLocation>(
                  isExpanded: true,
                  hint: const Text('Choose location'),
                  value: assessment.testLocation,
                  items: TestLocation.values
                      .map(
                        (l) => DropdownMenuItem(
                          value: l,
                          child: Text(l.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => assessment.testLocation = value),
                ),
              ),
            ),
            _FieldRow(
              label: 'Test Administrator 1',
              child: TextField(
                controller: _admin1Controller,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            _FieldRow(
              label: 'Test Administrator 2',
              subLabel: 'Optional',
              child: TextField(
                controller: _admin2Controller,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ],
        ),
      ),
      bottomBar: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _submitting ? null : () => _submit(session),
          child: _submitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text('Next'),
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.child,
    this.subLabel,
    this.onTap,
  });

  final String label;
  final String? subLabel;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                if (subLabel != null)
                  Text(
                    subLabel!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );

    return Column(
      children: [
        onTap == null ? row : InkWell(onTap: onTap, child: row),
        const Divider(height: 1),
      ],
    );
  }
}
