import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/drug.dart';

class DrugRepository {
  List<Drug>? _cache;

  Future<List<Drug>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/drugs.json');
    final List list = json.decode(raw) as List;
    _cache = list.map((e) => Drug.fromJson(e as Map<String, dynamic>)).toList();
    return _cache!;
  }
}
