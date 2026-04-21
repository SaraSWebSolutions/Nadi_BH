import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const baseUrl = "https://srv1252888.hstgr.cloud/api";
  final accountTypeId = "693175af976ca992c877f99d"; // Individual Account

  print("1. Creating user account wrapper...");
  var res1 = await http.post(
    Uri.parse("$baseUrl/user-account"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"accountTypeId": accountTypeId}),
  );

  if (res1.statusCode != 200 && res1.statusCode != 201) {
    print("Failed: ${res1.body}");
    return;
  }
  final userId = jsonDecode(res1.body)["userId"];
  print("User ID: $userId");

  var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  var loginEmail = "test$timestamp@nadi.com";
  var testPhone = timestamp.substring(3);

  print("2. Submitting basic info...");
  var res2 = await http.post(
    Uri.parse("$baseUrl/user-account/basic-info"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "userId": userId,
      "fullName": "Test",
      "secondName": "App",
      "thirdName": "Bot",
      "fourthName": "Runner",
      "mobileNumber": testPhone,
      "email": loginEmail,
      "password": "Password123@",
      "gender": "male"
    }),
  );


  if (res2.statusCode != 200 && res2.statusCode != 201) {
    print("Failed basic-info: ${res2.body}");
    return;
  }
  print("Success basic-info: ${res2.body}");

  print("Sending OTP...");
  var resOTP = await http.post(
    Uri.parse("$baseUrl/user-account/send-otp"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"userId": userId}),
  );
  print("OTP sent response: ${resOTP.body}");
  var otp = jsonDecode(resOTP.body)["otp"].toString();

  print("Verifying OTP...");
  var resVerify = await http.post(
    Uri.parse("$baseUrl/user-account/verify-otp"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"userId": userId, "otp": otp}),
  );
  print("Verify response: ${resVerify.body}");

  print("Accepting terms...");
  var resTerms = await http.post(
    Uri.parse("$baseUrl/user-account/terms-verify"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"userId": userId, "fcmToken": "dummy_fcm_token"}),
  );
  print("Terms response: ${resTerms.body}");

  print("Completing user account...");
  var resComplete = await http.post(
    Uri.parse("$baseUrl/user-account/complete"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"userId": userId}),
  );
  print("Complete response: ${resComplete.body}");

  print("3. Attempting login...");
  var res3 = await http.post(
    Uri.parse("$baseUrl/user-account/signin"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": loginEmail,
      "password": "Password123@",
      "fcmToken": "dummy_fcm_token"
    }),
  );

  print("Login response: ${res3.statusCode} -> ${res3.body}");
  print("------- GENERATED CREDENTIALS -------");
  print("Email: $loginEmail");
  print("Password: Password123@");
  print("Phone: $testPhone");
}
