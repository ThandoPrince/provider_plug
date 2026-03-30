import 'package:flutter/material.dart';

class TabIndexNotifier with ChangeNotifier {
  int _index = 0;

  int get index => _index;

  void setIndex(int index) {
    _index = index;
    notifyListeners();
  }

  void reset() {
    _index = 0;
    notifyListeners();
  }
}