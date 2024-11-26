import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static String userIdKey = 'USERKEY';
  static String userNameKey = 'USERNAMEKEY';
  static String userEmailKey = 'USEREMAILKEY';
  static String userPicKey = 'USERPICKEY';
  static String displaynameKey = 'USERDISPLAYNAME';
  static String roleKey = 'USERROLEKEY'; // Added missing role key

  Future<bool> saveUserId(String getuserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, getuserId);
  }

  Future<bool> saveUserName(String getuserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, getuserName);
  }

  Future<bool> saveUserEmail(String getUserEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, getUserEmail);
  }

  Future<bool> saveUserPic(String getUserPic) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userPicKey, getUserPic);
  }

  Future<bool> saveUserDisplayName(String getUserDisplayName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(displaynameKey, getUserDisplayName);
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String?> getUserPic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userPicKey);
  }

  Future<String?> getDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(displaynameKey);
  }

  Future<bool> saveUserRole(String getUserRole) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(roleKey, getUserRole); // Corrected variable name
  }

  Future<String?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(roleKey); // Added getter method for user role
  }
}
