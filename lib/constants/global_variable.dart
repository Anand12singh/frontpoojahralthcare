import 'package:shared_preferences/shared_preferences.dart';

class Global{
  static String? status;
  static String? patient_id;
  static String? phid;
  static String? phid1;

}

class AppState {
  static const String _selectedPageIndexKey = 'selectedPageIndex';

  static Future<int> getSelectedPageIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_selectedPageIndexKey) ?? 0;
  }

  static Future<void> setSelectedPageIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selectedPageIndexKey, index);
  }
}

int selectedPageIndex = 0;
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