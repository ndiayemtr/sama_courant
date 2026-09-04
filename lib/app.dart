import 'package:flutter/material.dart';
import 'package:sama_courant/core/router/app_router.dart';
import 'package:sama_courant/core/theme/app_theme.dart';

class SamaCourantApp extends StatelessWidget {
  const SamaCourantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sama Courant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
