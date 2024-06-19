import 'dart:math';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart' show IOClient, IOStreamedResponse;
import 'package:http/http.dart' show BaseRequest, Response;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:sysadmindb/app/models/user.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchGMail extends StatefulWidget {
  const LaunchGMail({super.key});

  @override
  State<LaunchGMail> createState() => _LaunchGMailState();
}

class _LaunchGMailState extends State<LaunchGMail> {
  static const gmailurl = 'https://mail.google.com/a/dlsu.edu.ph';
  
  launchInbox(String gmail) async{

    if (await launchInbox(gmail)) {
      await launch(gmail);
    } else {
      throw 'Could not open $gmail';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return launchInbox(gmailurl);
  }
}