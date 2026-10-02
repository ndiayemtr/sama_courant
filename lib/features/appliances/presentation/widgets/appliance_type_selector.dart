import 'package:flutter/material.dart';

import '../models/appliance_visual.dart';

class ApplianceTypeSelector extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const ApplianceTypeSelector({super.key, required this.onSelected});

  static const _types = <String>[
    'refrigerator',
    'freezer',
    'air_conditioner',
    'fan',
    'iron',
    'washing_machine',
    'microwave',
    'electric_oven',
    'rice_cooker',
    'television',
    'decoder_box',
    'router_modem',
    'computer_laptop',
    'water_heater',
    'water_pump',
    'light_bulb',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 170,
      ),
      itemCount: _types.length,
      itemBuilder: (context, index) {
        final type = _types[index];
        final visual = ApplianceVisualCatalog.resolve(type);

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onSelected(type),
          child: Ink(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: visual.assetPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              visual.assetPath!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Icon(
                            visual.icon,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    visual.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
