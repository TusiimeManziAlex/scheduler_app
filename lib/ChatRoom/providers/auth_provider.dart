// import 'package:chat_app/constants/Error.dart';
// import 'package:chat_app/resources/FirebaseMethod.dart';
// import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  String errormsg = "";
  bool isLoading = false;
  String otp = "";

  void setSignIn(String phonenumber, BuildContext context) async {
    isLoading = true;
    print("From Provider");
    print(isLoading);
    notifyListeners();
    // final result = await FirebaseMethods().signIn(phonenumber, context);
    // result.fold((left) async => errormsg = left.errormsg, (right) => "");
    isLoading = false;
    print(isLoading);
    notifyListeners();
  }

  Future<void> setOtp(String lotp) async {
    otp = lotp;
    notifyListeners();
  }
}
