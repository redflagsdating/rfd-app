import 'package:flutter/material.dart';
import 'package:red_flags/theme/color_schemes.g.dart';

final chipTheme = ChipThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  side: MaterialStateBorderSide.resolveWith(
    (states) {
      if (!states.contains(MaterialState.selected)) {
        return BorderSide(color: lightColorScheme.outlineVariant);
      }

      return null;
    },
  ),
  color: MaterialStateProperty.resolveWith(
    (states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
        MaterialState.selected,
      };
      if (states.any(interactiveStates.contains)) {
        return lightColorScheme.inversePrimary;
      }

      return null;
    },
  ),
);
