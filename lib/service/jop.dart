import 'package:flutter/material.dart';
import 'package:reminder_app/constants.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  await launchUrl(launchUri);
}

Future<void> openUrl(String url) async {
  final Uri _url = Uri.parse(url);
  if (!await launchUrl(_url)) showToastMessage('Could not launch $_url', Colors.black, 20);
}

Future<void> sendEmail(String mailAddress, String subject, String body) async {
  final Uri launchUri = Uri(
    scheme: 'mailto',
    path: mailAddress,
    query: 'subject=$subject&body=$body',
  );
  await launchUrl(launchUri);
}

Future<void> sendSms(String phoneNumber, String sms) async {
  final Uri launchUri = Uri(
    scheme: 'smsto',
    path: phoneNumber,
    query: 'body=$sms',
  );
  await launchUrl(launchUri);
}

enum JobType {
  none("none"),
  makePhoneCall("phone call"),
  sendEmail("send email"),
  sendSms("send sms"),
  openUrl("open url");

  const JobType(this.value);
  final String value;
}
