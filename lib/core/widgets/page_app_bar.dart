import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Sizes the toolbar to its title so enlarged text remains fully readable.
AppBar pageAppBar({
  required BuildContext context,
  required String title,
  bool automaticallyImplyLeading = true,
  List<Widget>? actions,
}) {
  final theme = Theme.of(context);
  final hasBack = automaticallyImplyLeading && Navigator.of(context).canPop();
  final width =
      MediaQuery.sizeOf(context).width -
      32 -
      (hasBack ? 56 : 0) -
      (actions?.length ?? 0) * 48;
  final painter = TextPainter(
    text: TextSpan(
      text: title,
      style: theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge,
    ),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout(maxWidth: math.max(1, width));
  final height = math.max(kToolbarHeight, painter.height + 16);
  painter.dispose();
  return AppBar(
    title: Text(title, softWrap: true, overflow: TextOverflow.visible),
    automaticallyImplyLeading: automaticallyImplyLeading,
    actions: actions,
    toolbarHeight: height,
  );
}
