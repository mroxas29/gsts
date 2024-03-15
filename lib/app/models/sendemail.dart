import 'dart:convert';

import 'package:http/http.dart' as http;

Future sendEmail(
    {required String? firstname,
    required String? email,
    required String? toemail,
    required String? subject,
    required String? password}) async {
  final serviceId = 'service_aebxb15';
  final templateId = 'template_btx1fyj';
  final userId = 'x-YcyTh13WaC9vUVB';
  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  final response = await http.post(url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'to_email': toemail,
          'to_name': firstname,
          'user_email': email,
          'user_subject': subject,
          'password': password,
        }
      }));

  print(response.body);
}

Future sendEmailWarning(
    {required String? firstname,
    required String? email,
    required String? toemail,
    required String? subject,
  }) async {
  final serviceId = 'service_aebxb15';
  final templateId = 'template_qyboock';
  final userId = 'x-YcyTh13WaC9vUVB';
  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  final response = await http.post(url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'to_email': toemail,
          'to_name': firstname,
          'user_email': email,
          'user_subject': subject,
        }
      }));

  print(response.body);
}
