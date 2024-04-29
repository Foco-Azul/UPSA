import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutkit/custom/auth/login_screen.dart';
import 'package:provider/provider.dart';

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

  void logout(BuildContext context) {
    Provider.of<AppNotifier>(context, listen: false).limpiarValores();
    Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomesScreen()),(Route<dynamic> route) => false);
    //Get.back();
    // Navigator.pop(context);
  }
}
