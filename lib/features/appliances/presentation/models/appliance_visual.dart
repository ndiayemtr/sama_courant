import 'package:flutter/material.dart';

class ApplianceVisual {
  final String label;
  final IconData icon;

  const ApplianceVisual({required this.label, required this.icon});
}

class ApplianceVisualCatalog {
  const ApplianceVisualCatalog._();

  static const Map<String, ApplianceVisual> _visuals = {
    // --- FROID ET CLIMATISATION ---
    'refrigerator': ApplianceVisual(
      label: 'Réfrigérateur',
      icon: Icons.kitchen_outlined,
    ),
    'freezer': ApplianceVisual(label: 'Congélateur', icon: Icons.ac_unit),
    'air_conditioner': ApplianceVisual(
      label: 'Climatiseur',
      icon: Icons.ac_unit,
    ),
    'fan': ApplianceVisual(label: 'Ventilateur', icon: Icons.air),
    'dehumidifier_humidifier': ApplianceVisual(
      label: 'Déshumidificateur / humidificateur',
      icon: Icons.water_drop_outlined,
    ),
    'air_purifier': ApplianceVisual(
      label: 'Purificateur d\'air',
      icon: Icons.filter_alt_outlined,
    ),
    'radiator_heater': ApplianceVisual(
      label: 'Radiateur / Chauffage',
      icon: Icons.thermostat_outlined,
    ),

    // --- ENTRETIEN DU LINGE & MAISON ---
    'iron': ApplianceVisual(label: 'Fer à repasser', icon: Icons.iron_outlined),
    'washing_machine': ApplianceVisual(
      label: 'Machine à laver',
      icon: Icons.local_laundry_service_outlined,
    ),
    'dryer': ApplianceVisual(
      label: 'Sèche-linge',
      icon: Icons.dry_cleaning_outlined,
    ),
    'vacuum_cleaner': ApplianceVisual(
      label: 'Aspirateur',
      icon: Icons.cleaning_services_outlined,
    ),
    'robot_vacuum': ApplianceVisual(
      label: 'Aspirateur robot',
      icon: Icons.smart_toy_outlined,
    ),
    'steam_cleaner': ApplianceVisual(
      label: 'Nettoyeur vapeur',
      icon: Icons.cleaning_services_outlined,
    ),

    // --- CUISINE ---
    'microwave': ApplianceVisual(
      label: 'Micro-ondes',
      icon: Icons.microwave_outlined,
    ),
    'electric_oven': ApplianceVisual(
      label: 'Four électrique',
      icon: Icons.local_fire_department_outlined,
    ),
    'electric_cooktop': ApplianceVisual(
      label: 'Plaque de cuisson',
      icon: Icons.countertops_outlined,
    ),
    'range_hood': ApplianceVisual(
      label: 'Hotte aspirante',
      icon: Icons.soup_kitchen_outlined,
    ),
    'rice_cooker': ApplianceVisual(
      label: 'Cuiseur de riz',
      icon: Icons.rice_bowl_outlined,
    ),
    'air_fryer': ApplianceVisual(
      label: 'Air fryer',
      icon: Icons.local_fire_department_outlined,
    ),
    'kettle': ApplianceVisual(
      label: 'Bouilloire',
      icon: Icons.emoji_food_beverage_outlined,
    ),
    'coffee_maker': ApplianceVisual(
      label: 'Cafetière',
      icon: Icons.coffee_outlined,
    ),
    'toaster': ApplianceVisual(
      label: 'Grille-pain',
      icon: Icons.breakfast_dining_outlined,
    ),
    'blender_mixer': ApplianceVisual(
      label: 'Mixeur / Blender',
      icon: Icons.blender_outlined,
    ),
    'food_processor': ApplianceVisual(
      label: 'Robot ménager',
      icon: Icons.kitchen_outlined,
    ),

    // --- HIGHI-TECH & MULTIMÉDIA ---
    'television': ApplianceVisual(label: 'Téléviseur', icon: Icons.tv_outlined),
    'decoder_box': ApplianceVisual(
      label: 'Décodeur TV',
      icon: Icons.settings_input_component_outlined,
    ),
    'projector': ApplianceVisual(
      label: 'Vidéoprojecteur',
      icon: Icons.videocam_outlined,
    ),
    'router_modem': ApplianceVisual(
      label: 'Routeur / Modem',
      icon: Icons.router_outlined,
    ),
    'computer_laptop': ApplianceVisual(
      label: 'Ordinateur portable',
      icon: Icons.laptop_outlined,
    ),
    'desktop_pc': ApplianceVisual(
      label: 'Ordinateur fixe',
      icon: Icons.computer_outlined,
    ),
    'monitor_screen': ApplianceVisual(
      label: 'Écran / Moniteur',
      icon: Icons.monitor_outlined,
    ),
    'gaming_console': ApplianceVisual(
      label: 'Console de jeux',
      icon: Icons.sports_esports_outlined,
    ),
    'audio_system': ApplianceVisual(
      label: 'Système audio / Enceinte',
      icon: Icons.speaker_outlined,
    ),
    'printer_scanner': ApplianceVisual(
      label: 'Imprimante / Scanner',
      icon: Icons.print_outlined,
    ),
    'charger': ApplianceVisual(
      label: 'Chargeur',
      icon: Icons.battery_charging_full,
    ),

    // --- HYGIÈNE & BEAUTÉ ---
    'hair_dryer': ApplianceVisual(label: 'Sèche-cheveux', icon: Icons.air),
    'hair_straightener': ApplianceVisual(
      label: 'Lisseur / Fer à boucler',
      icon: Icons.strikethrough_s_outlined,
    ),
    'electric_shaver': ApplianceVisual(
      label: 'Rasoir / Tondeuse',
      icon: Icons.face_outlined,
    ),
    'electric_toothbrush': ApplianceVisual(
      label: 'Brosse à dents électrique',
      icon: Icons.clean_hands_outlined,
    ),

    // --- SÉCURITÉ & DOMOTIQUE ---
    'security_camera': ApplianceVisual(
      label: 'Caméra de surveillance',
      icon: Icons.videocam_outlined,
    ),
    'alarm_system': ApplianceVisual(
      label: 'Système d\'alarme',
      icon: Icons.security_outlined,
    ),
    'smart_lock': ApplianceVisual(
      label: 'Serrure connectée',
      icon: Icons.lock_outlined,
    ),

    // --- INFRASTRUCTURE, EAU & ÉNERGIE ---
    'water_heater': ApplianceVisual(
      label: 'Chauffe-eau',
      icon: Icons.hot_tub_outlined,
    ),
    'water_pump': ApplianceVisual(
      label: 'Pompe à eau',
      icon: Icons.water_outlined,
    ),
    'light_bulb': ApplianceVisual(
      label: 'Éclairage',
      icon: Icons.lightbulb_outline,
    ),
    'voltage_regulator': ApplianceVisual(
      label: 'Régulateur de tension',
      icon: Icons.electric_meter_outlined,
    ),
    'ups_inverter': ApplianceVisual(
      label: 'Onduleur / Inverter',
      icon: Icons.power_outlined,
    ),
    'solar_panel': ApplianceVisual(
      label: 'Panneau solaire',
      icon: Icons.wb_sunny_outlined,
    ),
    'ev_charger': ApplianceVisual(
      label: 'Borne de recharge véhicule',
      icon: Icons.ev_station_outlined,
    ),

    // --- OUTILLAGE & JARDIN ---
    'lawn_mower': ApplianceVisual(
      label: 'Tondeuse à gazon',
      icon: Icons.grass_outlined,
    ),
    'power_tools': ApplianceVisual(
      label: 'Outillage électrique (Perceuse, etc.)',
      icon: Icons.build_outlined,
    ),
  };

  static ApplianceVisual resolve(String category) {
    return _visuals[category] ??
        ApplianceVisual(
          label: category,
          icon: Icons.electrical_services_outlined,
        );
  }

  static String? labelForType(String? applianceType) {
    if (applianceType == null) {
      return null;
    }

    return _visuals[applianceType]?.label;
  }
}
