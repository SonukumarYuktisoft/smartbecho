import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

SpeedDialChild buildSpeedDialChild({
  required String label,
  required Color backgroundColor,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return SpeedDialChild(
    child: Icon(icon, color: Colors.white),
    backgroundColor: backgroundColor,
    label: label,
    labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    onTap: onTap,
  );
}
