enum AssessmentType {
  clinical,
  research;

  String get label {
    switch (this) {
      case AssessmentType.clinical:
        return 'Clinical';
      case AssessmentType.research:
        return 'Research';
    }
  }

  String get dbValue => name;
}

enum TestLocation {
  medicalFacility,
  home,
  nursingHome;

  String get label {
    switch (this) {
      case TestLocation.medicalFacility:
        return 'Medical facility';
      case TestLocation.home:
        return 'Home';
      case TestLocation.nursingHome:
        return 'Nursing home';
    }
  }

  String get dbValue => name;
}
 
//Assessment header
class Assessment {
  DateTime date;
  AssessmentType? assessmentType;
  String patientFirstName;
  String patientLastName;
  String physicianFirstName;
  String physicianLastName;
  TestLocation? testLocation;
  String testAdministrator1;
  String testAdministrator2;

  Assessment({
    DateTime? date,
    this.assessmentType,
    this.patientFirstName = '',
    this.patientLastName = '',
    this.physicianFirstName = '',
    this.physicianLastName = '',
    this.testLocation,
    this.testAdministrator1 = '',
    this.testAdministrator2 = '',
  }) : date = date ?? DateTime.now();

  bool get isReadyForNext =>
      assessmentType != null &&
      patientFirstName.trim().isNotEmpty &&
      patientLastName.trim().isNotEmpty &&
      testLocation != null &&
      testAdministrator1.trim().isNotEmpty;
}
