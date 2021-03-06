import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../calculation_model.dart';

class CalculationHistoryService {
  static String _sharedPreferenceKey = 'calculation_history';

  CalculationHistoryService({
    @required this.sharedPreferences
  }) : assert (sharedPreferences != null);

  SharedPreferences sharedPreferences;

  List<CalculationModel> fetchAllEntries() {
    List<CalculationModel> result = <CalculationModel>[];

    if (!sharedPreferences.containsKey(_sharedPreferenceKey)) {
      return [];
    }

    List<dynamic> history = [];

    try {
      history = jsonDecode(
          sharedPreferences.getString(_sharedPreferenceKey)
      );
    } on FormatException {
      sharedPreferences.remove(_sharedPreferenceKey);
    }

    for (Map<String, dynamic> entry in history) {
      result.add(
        CalculationModel.fromJson(entry)
      );
    }

    return result;
  }

  Future<bool> addEntry(CalculationModel model) async {
    List<CalculationModel> allEntries = fetchAllEntries();
    allEntries.add(model);

    return sharedPreferences.setString(
      _sharedPreferenceKey,
      jsonEncode(allEntries)
    );
  }
}