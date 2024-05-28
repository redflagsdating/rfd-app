import 'package:flutter/material.dart';
import 'package:red_flags/theme/color_schemes.g.dart';

final chipTheme = ChipThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  side: WidgetStateBorderSide.resolveWith(
    (states) {
      if (!states.contains(WidgetState.selected)) {
        return BorderSide(color: lightColorScheme.outlineVariant);
      }

      return null;
    },
  ),
  color: WidgetStateProperty.resolveWith(
    (states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
        WidgetState.selected,
      };
      if (states.any(interactiveStates.contains)) {
        return lightColorScheme.inversePrimary;
      }

      return null;
    },
  ),
);
