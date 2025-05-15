import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/locator.dart';
import 'package:http/http.dart' as http;

typedef ResSuccess = Future<void> Function(Map<String, dynamic>);
typedef ResFailure = Future<void> Function(dynamic);

class ServiceCall {
  static final NavigationService navigationService = locator<NavigationService>();
  static Map userPayload = {};

  static const String baseUrl = "http://10.0.2.2:3001/api"; // Pour l'émulateur Android

  static void post(Map<String, dynamic> parameter, String path,
      {bool isToken = false, ResSuccess? withSuccess, ResFailure? failure}) {
    Future(() async {
      try {
        var headers = {'Content-Type': 'application/json'};

        // Ajoutez un token si nécessaire
        if (isToken) {
          headers["Authorization"] = "Bearer YOUR_TOKEN_HERE";
        }

        final url = Uri.parse(path);
        print("Request URL: $url");
        print("Request Parameters: $parameter");

        final response = await http.post(
          url,
          body: jsonEncode(parameter),
          headers: headers,
        );

        if (kDebugMode) {
          print("Response Status Code: ${response.statusCode}");
          print("Response Body: ${response.body}");
        }

        if (response.statusCode == 200) {
          final jsonObj = json.decode(response.body) as Map<String, dynamic>? ?? {};
          if (withSuccess != null) withSuccess(jsonObj);
        } else {
          if (failure != null) failure("Erreur HTTP : ${response.statusCode}");
        }
      } catch (err) {
        if (kDebugMode) {
          print("Error: $err");
        }
        if (failure != null) failure(err.toString());
      }
    });
  }

  static void logout() {
    Globs.udBoolSet(false, Globs.userLogin);
    userPayload = {};
    navigationService.navigateTo("welcome");
  }
}