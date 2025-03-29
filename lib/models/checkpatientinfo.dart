// To parse this JSON data, do
//
//     final checkpatientinfo = checkpatientinfoFromJson(jsonString);

import 'dart:convert';

Checkpatientinfo checkpatientinfoFromJson(String str) =>
    Checkpatientinfo.fromJson(json.decode(str));

String checkpatientinfoToJson(Checkpatientinfo data) =>
    json.encode(data.toJson());

class Checkpatientinfo {
  bool status;
  String message;
  List<Datum> data;

  Checkpatientinfo({
    required this.status,
    required this.message,
    required this.data,
  });

  factory Checkpatientinfo.fromJson(Map<String, dynamic> json) =>
      Checkpatientinfo(
        status: json["status"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  int patientExist;
  String phid;

  Datum({
    required this.patientExist,
    required this.phid,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        patientExist: json["patientExist"],
        phid: json["phid"],
      );

  Map<String, dynamic> toJson() => {
        "patientExist": patientExist,
        "phid": phid,
      };
}
