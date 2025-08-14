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

  static const String _keyFirstName = 'first_name';
  static const String _keyLastName = 'last_name';
  static const String _keyPhone = 'phone';
  static const String _keyPatientExist = 'patient_exist';
  static const String _keyPatientId = 'patient_id';
  static const String _keyPhid = 'phid';

  /// Save data to SharedPreferences
  static Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFirstName, firstName ?? '');
    await prefs.setString(_keyLastName, lastName ?? '');
    await prefs.setString(_keyPhone, phone ?? '');
    await prefs.setInt(_keyPatientExist, patientExist ?? 0);
    await prefs.setString(_keyPatientId, patientId ?? '');
    await prefs.setString(_keyPhid, phid ?? '');
  }

  /// Load data from SharedPreferences
  static Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    firstName = prefs.getString(_keyFirstName);
    lastName = prefs.getString(_keyLastName);
    phone = prefs.getString(_keyPhone);
    patientExist = prefs.getInt(_keyPatientExist);
    patientId = prefs.getString(_keyPatientId);
    phid = prefs.getString(_keyPhid);
  }

  /// Clear static and SharedPreferences data
  static Future<void> clear() async {
    firstName = null;
    lastName = null;
    phone = null;
    patientExist = null;
    patientId = null;
    phid = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFirstName);
    await prefs.remove(_keyLastName);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyPatientExist);
    await prefs.remove(_keyPatientId);
    await prefs.remove(_keyPhid);
  }
}
