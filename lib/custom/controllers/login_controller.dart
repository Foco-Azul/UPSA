import 'package:get/get.dart';
import 'package:upsa/custom/auth/login_screen.dart';

class LoginController extends GetxController {
  bool showLoading = true, uiLoading = true;

  @override
  void onInit() {
    fetchData();
    super.onInit();
  }
  void fetchData() async {
    await Future.delayed(Duration(seconds: 1));
    showLoading = false;
    uiLoading = false;
    update();
  }
  
  void logIn() {
    Get.to(Login2Screen());
    // Navigator.push(context, MaterialPageRoute(builder: (context) => FullApp()));
  }

  void logout() {
    //Get.back();
    // Navigator.pop(context);
  }
}
