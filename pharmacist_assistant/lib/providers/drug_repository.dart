import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart' show rootBundle;

import '../models/drug.dart';

class DrugRepository {
  List<Drug>? _cache;

  Future<List<Drug>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/drugs.json');
    _cache = await compute(_parseDrugs, raw);
    return _cache!;
  }
}

List<Drug> _parseDrugs(String raw) {
  final List list = json.decode(raw) as List;
  return list
      .map((e) => Drug.fromJson(e as Map<String, dynamic>))
      .toList(growable: false);
}
