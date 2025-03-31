import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum HTTPMethod { GET, POST, PUT, DELETE }

class ConnectionDetector {
  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true; // Internet is available
      }
    } catch (_) {
      // Internet is not available
    }
    return false;
  }
}

class ConfigManager {
  static String baseURL = 'https://pooja-healthcare.ortdemo.com/';
  static String apiVersion = '';
  static Duration timeout = Duration();

  static void loadConfiguration(String configString) {
    Map config = jsonDecode(configString);
    var env = config['environment'];
    baseURL = config[env]['hostUrl'];
    apiVersion = config['version'];
    timeout = Duration(seconds: config[env]['timeout']);
    print('Configuration loaded: $configString');
  }

  static String getBaseURL() {
    return baseURL;
  }
}

// api/api_endpoints.dart
enum API {
  // General
  getLocation,
  addPatient

  // Other APIs as required...
}

class APIManager {
  static final APIManager _instance = APIManager._privateConstructor();

  APIManager._privateConstructor();

  factory APIManager() {
    return _instance;
  }
  //String? userId =  UserManager().getUserId() ; // Modify the method as per your UserManager
  Future<String> apiEndPoint(API api,
      {Map<String, dynamic>? queryParams}) async {
    var apiPathString = "";

    switch (api) {
      case API.getLocation:
        apiPathString = "api/getlocation";
        break;
      case API.addPatient:
        apiPathString = "api/storepatient";
        break;
      default:
        apiPathString = "HomeheaderResponse";
    }

    print("URL:");
    print("${ConfigManager.getBaseURL() + apiPathString}");
    return ConfigManager.getBaseURL() + apiPathString;
  }

  HTTPMethod apiHTTPMethod(API api) {
    switch (api) {
      case API.addPatient:
        return HTTPMethod.POST;
      default:
        return HTTPMethod.GET;
    }
  }

  Future<void> apiRequest(
    BuildContext context,
    API api, {
    required dynamic params,
    required Function onSuccess,
    required Function onFailure,
    String? contactid,
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    final isConnected = await ConnectionDetector.checkInternetConnection();

    if (!isConnected) {
      onFailure("Please check your Internet Connection.");
      return; // Exit early if no internet connection
    }

    try {
      // Pass the queryParams when calling apiEndPoint
      final String url = await apiEndPoint(api, queryParams: queryParams);
      final body = params != null && params.isNotEmpty
          ? jsonEncode(params) // Send JSON when params exist
          : null;

      var response;

      // Define headers
      Map<String, String> headers = {
        //"Content-Type": "application/x-www-form-urlencoded",
        'Content-Type': 'application/json',
      };

      // Add Authorization Bearer token if provided
      if (token != null && token.isNotEmpty) {
        print("token : $token");
        headers['Authorization'] = 'Bearer $token';
      }

      // Detect if there are any files in params
      bool hasFiles = params != null &&
          (params['adhaar_image'] != null || params['pancard_image'] != null);

      // Debugging details
      print("Request URL: $url");
      print("Request Headers: $headers");
      print("Request Params: $params");

      // Choose HTTP method based on the API type
      if (apiHTTPMethod(api) == HTTPMethod.GET) {
        // Send GET request with token in headers
        response = await http
            .get(
              Uri.parse(url),
              headers: headers,
            )
            .timeout(const Duration(seconds: 30));
      } else {
        // Check if any file is being uploaded
        if (params != null &&
            (params['adhaar_front_image'] != null ||
                params['adhaar_back_image'] != null ||
                params['pancard_image'] != null)) {
          var request = http.MultipartRequest("POST", Uri.parse(url));

          // Add headers to multipart request
          request.headers.addAll(headers);

          // Add normal params to the request
          params.forEach((key, value) {
            if (value != null &&
                key != 'adhaar_front_image' &&
                key != 'adhaar_back_image' &&
                key != 'pancard_image') {
              request.fields[key] = value.toString();
            }
          });

          // Add Aadhaar image if present
          if (params['adhaar_front_image'] != null) {
            request.files.add(await http.MultipartFile.fromPath(
                'adhaar_front_image', params['adhaar_front_image']));
          }

          if (params['adhaar_back_image'] != null) {
            request.files.add(await http.MultipartFile.fromPath(
                'adhaar_back_image', params['adhaar_back_image']));
          }

          // Add Pancard image if present
          if (params['pancard_image'] != null) {
            request.files.add(await http.MultipartFile.fromPath(
                'pancard_image', params['pancard_image']));
          }

          // Send the multipart request
          response = await http.Response.fromStream(await request.send());
        } else {
          // Send POST request without files
          response = await http
              .post(
                Uri.parse(url),
                headers: headers,
                body: body,
              )
              .timeout(const Duration(seconds: 30));
        }
      }

      /*if (apiHTTPMethod(api) == HTTPMethod.GET) {
        // Send GET request with token in headers
        response = await http.get(
          Uri.parse(url),
          headers: headers,
        ).timeout(const Duration(seconds: 30)); // Set the timeout to 30 seconds
      } else {
        // Send POST request
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          */ /*body: params != null
              ? Uri(queryParameters: params).query // Encode parameters as form-data
              : null,*/ /*
          body: body,
          //body: jsonEncode(params)
        ).timeout(const Duration(seconds: 30)); // Set the timeout to 30 seconds
      }*/

      // Handle response
      if (response.statusCode == 200) {
        onSuccess(response.body);
        print("params");
        print(params.toString());
      } else {
        onFailure('Error: ${response.statusCode}');
        print("params");
        print(params.toString());
      }
    } catch (e) {
      if (e is TimeoutException) {
        onFailure("Request timed out. Please try again later.");
      } else {
        onFailure("Request failed: $e");
      }
    }
  }
}
