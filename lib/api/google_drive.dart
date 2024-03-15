import 'dart:io';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:sysadmindb/main.dart';
import 'package:sysadmindb/ui/EventDetailsScreen.dart';

const clientId =
    "703443900752-d0o2p65v12dkmfq8vt4dd8pmtp3k7ish.apps.googleusercontent.com";
const clientSecret = "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";
final scopes = [drive.DriveApi.driveScope];

class GoogleDrive {


   Future<drive.DriveApi> getDriveClient() async {
     final credentials = ServiceAccountCredentials.fromJson({
      "private_key": "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",
      "client_email": "703443900752-d0o2p65v12dkmfq8vt4dd8pmtp3k7ish.apps.googleusercontent.com",
    });
    final client = await clientViaUserConsent(
        ClientId(clientId, clientSecret), scopes,prompt);

    return drive.DriveApi(client);
  }

 Future<void> uploadFile(File file) async {
    final driveApi = await getDriveClient();

    try {
      final response = await driveApi.files.create(
        drive.File()..name = file.path.split('/').last,
        uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
      );

      print('File uploaded: ${response.name} (${response.id})');
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

}
