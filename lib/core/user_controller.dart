import 'package:get/get.dart';

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
}
