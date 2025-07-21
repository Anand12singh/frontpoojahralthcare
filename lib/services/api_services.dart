import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum HTTPMethod { GET, POST, PUT, DELETE }

class ConnectionDetector {
  static Future<bool> checkInternetConnection() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}

class ConfigManager {
  static String baseURL = 'https://uatpoojahealthcare.ortdemo.com/api';
  static String apiVersion = '';
  static Duration timeout = const Duration(seconds: 30);

  static void loadConfiguration(String configString) {
    Map config = jsonDecode(configString);
    var env = config['environment'];
    baseURL = config[env]['hostUrl'];
    apiVersion = config['version'];
    timeout = Duration(seconds: config[env]['timeout']);
    print('Configuration loaded: $configString');
  }

  static String getBaseURL() => baseURL;
}

enum API {
  getlocation,
  frontpatientbyid,
  getallusers,
  getAllRoles,
  getuserpermissons,
  addPatient,
  updateUserById,
  getPatientById,
  getUserById,
  getrolebyid,
  createRole,
  createUser,
  deleteRoleById,
  deleteUserById,
  updateRoleById,
  activeUserById,
  summaryadd,
  savepermissions,
  globalpermission,
  permissionslist,
  checkpatientinfo,
}

class APIManager {
  static final APIManager _instance = APIManager._privateConstructor();

  APIManager._privateConstructor();

  factory APIManager() => _instance;

  /// Returns the API endpoint path for a given API enum.
  Future<String> apiEndPoint(API api) async {
    switch (api) {

      case API.addPatient:
        return '${ConfigManager.getBaseURL()}/api/storepatient';
      case API.getPatientById:
        return '${ConfigManager.getBaseURL()}/getpatientbyid';
        case API.frontpatientbyid:
        return '${ConfigManager.getBaseURL()}/front_patient_by_id';
        case API.summaryadd:
        return '${ConfigManager.getBaseURL()}/summary_add';
        case API.checkpatientinfo:
        return '${ConfigManager.getBaseURL()}/checkpatientinfo';
        case API.getlocation:
        return '${ConfigManager.getBaseURL()}/getlocation';
        case API.getallusers:
        return '${ConfigManager.getBaseURL()}/get_allusers';
        case API.getAllRoles:
        return '${ConfigManager.getBaseURL()}/getAllRoles';
        case API.updateUserById:
        return '${ConfigManager.getBaseURL()}/updateUserById';
        case API.createRole:
        return '${ConfigManager.getBaseURL()}/createRole';
        case API.deleteRoleById:
        return '${ConfigManager.getBaseURL()}/deleteRoleById';
        case API.updateRoleById:
        return '${ConfigManager.getBaseURL()}/updateRoleById';
        case API.deleteUserById:
        return '${ConfigManager.getBaseURL()}/deleteUserById';
        case API.getrolebyid:
        return '${ConfigManager.getBaseURL()}/getrole_by_id';
        case API.createUser:
        return '${ConfigManager.getBaseURL()}/createUser';
        case API.getUserById:
        return '${ConfigManager.getBaseURL()}/getUserById';
        case API.globalpermission:
        return '${ConfigManager.getBaseURL()}/global_permission';
        case API.getuserpermissons:
        return '${ConfigManager.getBaseURL()}/get_user_permissons';
        case API.activeUserById:
        return '${ConfigManager.getBaseURL()}/activeUserById';
        case API.permissionslist:
        return '${ConfigManager.getBaseURL()}/permissions_list';
        case API.savepermissions:
        return '${ConfigManager.getBaseURL()}/save_permissions';
      default:
        throw Exception('API not defined');
    }
  }

  /// Returns HTTP method type for the API.
  HTTPMethod apiHTTPMethod(API api) {
    switch (api) {
      case API.addPatient:
      case API.getPatientById:
      case API.frontpatientbyid:
      case API.checkpatientinfo:
      case API.summaryadd:
      case API.getAllRoles:
      case API.getallusers:
      case API.deleteUserById:
      case API.getUserById:
      case API.permissionslist:
      case API.getrolebyid:
      case API.globalpermission:
      case API.getuserpermissons:
      case API.savepermissions:

      case API.createRole:
      case API.createUser:
      case API.updateUserById:
      case API.activeUserById:
      case API.deleteRoleById:
      case API.updateRoleById:
        return HTTPMethod.POST;
      default:
        return HTTPMethod.GET;
    }
  }

  /// Main method to perform API requests.
  Future<void> apiRequest(
      BuildContext context,
      API api, {
        dynamic params,
        required Function(String) onSuccess,
        required Function(String) onFailure,
        String? token,
      }) async {
    final isConnected = await ConnectionDetector.checkInternetConnection();

    if (!isConnected) {
      onFailure("Please check your Internet Connection.");
      return;
    }

    try {
      final url = await apiEndPoint(api);
      final method = apiHTTPMethod(api);
      final headers = {
        "Accept":'application/json',
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      };

      print("Request URL: $url");
      print("Request Headers: $headers");
      print("Request Params: $params");

      http.Response response;

      if (method == HTTPMethod.GET) {
        response = await http
            .get(Uri.parse(url), headers: headers)
            .timeout(ConfigManager.timeout);
      } else {
        if (_containsFileParams(params)) {
          response = await _sendMultipartRequest(url, params, headers);
        } else {
          response = await http
              .post(
            Uri.parse(url),
            headers: headers,
            body: params != null ? jsonEncode(params) : null,
          )
              .timeout(ConfigManager.timeout);
        }
      }

      if (response.statusCode == 200) {
        onSuccess(response.body);
      } else {
        onFailure('Error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        onFailure("Request timed out. Please try again later.");
      } else {
        onFailure("Request failed:$e");
      }
    }
  }

  /// Helper to check if parameters contain file uploads.
  bool _containsFileParams(Map? params) {
    if (params == null) return false;
    return params.containsKey('adhaar_front_image') ||
        params.containsKey('adhaar_back_image') ||
        params.containsKey('pancard_image');
  }

  /// Handles multipart file upload requests.
  Future<http.Response> _sendMultipartRequest(
      String url,
      Map params,
      Map<String, String> headers,
      ) async {
    var request = http.MultipartRequest("POST", Uri.parse(url))
      ..headers.addAll(headers);

    // Add regular fields
    params.forEach((key, value) {
      if (value != null &&
          key != 'adhaar_front_image' &&
          key != 'adhaar_back_image' &&
          key != 'pancard_image') {
        request.fields[key] = value.toString();
      }
    });

    // Add files if present
    if (params['adhaar_front_image'] != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'adhaar_front_image', params['adhaar_front_image']));
    }

    if (params['adhaar_back_image'] != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'adhaar_back_image', params['adhaar_back_image']));
    }

    if (params['pancard_image'] != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'pancard_image', params['pancard_image']));
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
