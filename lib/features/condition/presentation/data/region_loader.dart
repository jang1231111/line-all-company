import 'dart:convert';
import 'package:flutter/services.dart';

class RegionHierarchy {
  final List<String> sidos;
  final Map<String, List<String>> sigungus;
  final Map<String, List<String>> eupmyeondongs;
  final Map<String, List<String>> beopjeongdongs;

  RegionHierarchy({
    required this.sidos,
    required this.sigungus,
    required this.eupmyeondongs,
    required this.beopjeongdongs,
  });

  factory RegionHierarchy.fromJson(Map<String, dynamic> json) {
    return RegionHierarchy(
      sidos: List<String>.from(json['sidos']),
      sigungus: (json['sigungus'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, List<String>.from(v)),
      ),
      eupmyeondongs: (json['eupmyeondongs'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, List<String>.from(v)),
      ),
      beopjeongdongs: (json['beopjeongdongs'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, List<String>.from(v)),
      ),
    );
  }
}

Future<RegionHierarchy> loadRegionHierarchy() async {
  final jsonStr = await rootBundle.loadString('lib/assets/destination_hierarchy.json');
  final jsonMap = json.decode(jsonStr);
  return RegionHierarchy.fromJson(jsonMap);
}