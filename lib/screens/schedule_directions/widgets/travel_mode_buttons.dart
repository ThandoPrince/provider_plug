import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';


enum TravelMode { car, pedestrian, bicycle, scooter }

class TravelModeSelector extends StatelessWidget {
  final TravelMode selectedMode;
  final Function(TravelMode) onModeSelected;

  const TravelModeSelector({super.key, required this.selectedMode, required this.onModeSelected});

  Widget _modeButton(TravelMode mode, IconData icon) {
    final selected = selectedMode == mode;
    return GestureDetector(
      onTap: () => onModeSelected(mode),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: selected ? Kolors.kPrimary : Colors.grey.shade300,
        child: Icon(icon, color: selected ? Colors.white : Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _modeButton(TravelMode.car, Icons.directions_car),
        _modeButton(TravelMode.pedestrian, Icons.directions_walk),
        _modeButton(TravelMode.bicycle, Icons.directions_bike),
        _modeButton(TravelMode.scooter, Icons.electric_scooter),
      ],
    );
  }
}
