import 'package:flutter/material.dart';

class DrawerNotifier with ChangeNotifier{
int _tile_index = 0;

int get getTileIndex => _tile_index;

void setTileIndex(int index){
  _tile_index = index;
  notifyListeners();
}
}