import 'package:flutter/material.dart';

class AppliancesLoading extends StatelessWidget {
  const AppliancesLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement de vos appareils...', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
