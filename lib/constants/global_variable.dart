class Global{
  static String? status;
  static String? patient_id;
  static String? phid;
  static String? phid1;

}

class GlobalPatientData {
  static String? firstName;
  static String? lastName;
  static String? phone;
  static int? patientExist;
  static String? patientId;
  static String? phid;

  static void clear() {
    firstName = null;
    lastName = null;
    phone = null;
    patientExist = null;
    patientId = null;
    phid = null;
  }
}