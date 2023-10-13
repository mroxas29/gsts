import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/User.dart';

Container signInSignUpButton(
    BuildContext context, bool isLogin, Function onTap, bool isPressed) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton.icon(
      onPressed: () {
        onTap();
      },
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Color.fromARGB(68, 45, 107, 45);
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
      icon: isPressed
          ? Container(
              width: 24,
              height: 24,
              padding: const EdgeInsets.all(2.0),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
          : const Icon(Icons.lock),
      label: Text(isLogin ? 'LOG IN' : 'SIGN UP',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );
}

TextField resusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.white,
    style: TextStyle(color: Colors.white.withOpacity(0.9)),
    decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        labelText: text,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(width: 0, style: BorderStyle.none))),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

class LoaderDialog {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    var wid = MediaQuery.of(context).size.width / 2;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(left: 130, right: 130),
          child: Dialog(
              key: key,
              backgroundColor: Colors.white,
              child: SizedBox(
                width: 60.0,
                height: 60.0,
                child: Image.asset(
                  'images/loaderOld.gif',
                  height: 60,
                  width: 60,
                ),
              )),
        );
      },
    );
  }
}






 


