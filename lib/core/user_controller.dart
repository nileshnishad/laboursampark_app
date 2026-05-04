import 'package:get/get.dart';
import 'auth_service.dart';

class UserController extends GetxController {
  Rxn<Map<String, dynamic>> user = Rxn<Map<String, dynamic>>();
  RxnString token = RxnString();

  void setUser(Map<String, dynamic> userData, String authToken) {
    user.value = userData;
    token.value = authToken;
  }

  void clearUser() {
    user.value = null;
    token.value = null;
  }

  /// Restores session from SharedPreferences on app start.
  /// Returns true if session was restored successfully.
  Future<bool> restoreSession() async {
    final savedToken = await AuthService.getAuthToken();
    final savedUser = await AuthService.getUserData();
    if (savedToken != null && savedUser != null) {
      token.value = savedToken;
      user.value = savedUser;
      return true;
    }
    return false;
  }
}
