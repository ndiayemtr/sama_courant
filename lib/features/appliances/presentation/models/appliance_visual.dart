import 'package:flutter/material.dart';

class ApplianceVisual {
  final String label;
  final IconData icon;
  final String? assetPath;

  const ApplianceVisual({
    required this.label,
    required this.icon,
    this.assetPath,
  });
}

class ApplianceVisualCatalog {
  const ApplianceVisualCatalog._();

  static const Map<String, ApplianceVisual> _visuals = {
    // --- FROID ET CLIMATISATION ---
    'refrigerator': ApplianceVisual(
      label: 'Réfrigérateur',
      icon: Icons.kitchen_outlined,
      assetPath: 'assets/images/appliances/refrigerator.jpg',
    ),
    'freezer': ApplianceVisual(
      label: 'Congélateur',
      icon: Icons.ac_unit,
      assetPath: 'assets/images/appliances/freezer.jpg',
    ),
    'air_conditioner': ApplianceVisual(
      label: 'Climatiseur',
      icon: Icons.ac_unit,
      assetPath: 'assets/images/appliances/air_conditioner.jpg',
    ),
    'fan': ApplianceVisual(
      label: 'Ventilateur',
      icon: Icons.air,
      assetPath: 'assets/images/appliances/fan.jpg',
    ),
    'air_purifier': ApplianceVisual(
      label: 'Purificateur d\'air',
      icon: Icons.filter_alt_outlined,
      assetPath: 'assets/images/appliances/air_purifier.jpg',
    ),
    'radiator_heater': ApplianceVisual(
      label: 'Radiateur / Chauffage',
      icon: Icons.thermostat_outlined,
      assetPath: 'assets/images/appliances/radiator_heater.jpg',
    ),

    // --- ENTRETIEN DU LINGE & MAISON ---
    'iron': ApplianceVisual(
      label: 'Fer à repasser',
      icon: Icons.iron_outlined,
      assetPath: 'assets/images/appliances/iron.jpg',
    ),
    'dryer': ApplianceVisual(
      label: 'Sèche-linge',
      icon: Icons.dry_cleaning_outlined,
      assetPath: 'assets/images/appliances/dryer.jpg',
    ),
    'vacuum_cleaner': ApplianceVisual(
      label: 'Aspirateur',
      icon: Icons.cleaning_services_outlined,
      assetPath: 'assets/images/appliances/vacuum_cleaner.jpg',
    ),
    'robot_vacuum': ApplianceVisual(
      label: 'Aspirateur robot',
      icon: Icons.smart_toy_outlined,
      assetPath: 'assets/images/appliances/robot_vacuum.jpg',
    ),
    'steam_cleaner': ApplianceVisual(
      label: 'Nettoyeur vapeur',
      icon: Icons.cleaning_services_outlined,
      assetPath: 'assets/images/appliances/steam_cleaner.jpg',
    ),
    'washing_machine': ApplianceVisual(
      label: 'Machine à laver',
      icon: Icons.local_laundry_service_outlined,
      assetPath: 'assets/images/appliances/washing_machine.jpg',
    ),

    // --- CUISINE ---
    'microwave': ApplianceVisual(
      label: 'Micro-ondes',
      icon: Icons.microwave_outlined,
      assetPath: 'assets/images/appliances/microwave.jpg',
    ),
    'electric_oven': ApplianceVisual(
      label: 'Four électrique',
      icon: Icons.local_fire_department_outlined,
      assetPath: 'assets/images/appliances/electric_oven.jpg',
    ),
    'electric_cooktop': ApplianceVisual(
      label: 'Plaque de cuisson',
      icon: Icons.countertops_outlined,
      assetPath: 'assets/images/appliances/electric_cooktop.jpg',
    ),
    'range_hood': ApplianceVisual(
      label: 'Hotte aspirante',
      icon: Icons.soup_kitchen_outlined,
      assetPath: 'assets/images/appliances/range_hood.jpg',
    ),
    'rice_cooker': ApplianceVisual(
      label: 'Cuiseur de riz',
      icon: Icons.rice_bowl_outlined,
      assetPath: 'assets/images/appliances/rice_cooker.jpg',
    ),
    'air_fryer': ApplianceVisual(
      label: 'Air fryer',
      icon: Icons.local_fire_department_outlined,
      assetPath: 'assets/images/appliances/air_fryer.jpg',
    ),
    'kettle': ApplianceVisual(
      label: 'Bouilloire',
      icon: Icons.emoji_food_beverage_outlined,
      assetPath: 'assets/images/appliances/kettle.jpg',
    ),
    'coffee_maker': ApplianceVisual(
      label: 'Cafetière',
      icon: Icons.coffee_outlined,
      assetPath: 'assets/images/appliances/coffee_maker.jpg',
    ),
    'toaster': ApplianceVisual(
      label: 'Grille-pain',
      icon: Icons.breakfast_dining_outlined,
      assetPath: 'assets/images/appliances/toaster.jpg',
    ),
    'blender_mixer': ApplianceVisual(
      label: 'Mixeur / Blender',
      icon: Icons.blender_outlined,
      assetPath: 'assets/images/appliances/blender_mixer.jpg',
    ),
    'food_processor': ApplianceVisual(
      label: 'Robot ménager',
      icon: Icons.kitchen_outlined,
      assetPath: 'assets/images/appliances/food_processor.jpg',
    ),

    // --- HIGH-TECH & MULTIMÉDIA ---
    'television': ApplianceVisual(
      label: 'Téléviseur',
      icon: Icons.tv_outlined,
      assetPath: 'assets/images/appliances/television.jpg',
    ),
    'decoder_box': ApplianceVisual(
      label: 'Décodeur TV',
      icon: Icons.settings_input_component_outlined,
      assetPath: 'assets/images/appliances/decoder_box.jpg',
    ),
    'projector': ApplianceVisual(
      label: 'Vidéoprojecteur',
      icon: Icons.videocam_outlined,
      assetPath: 'assets/images/appliances/projector.jpg',
    ),
    'router_modem': ApplianceVisual(
      label: 'Routeur / Modem',
      icon: Icons.router_outlined,
      assetPath: 'assets/images/appliances/router_modem.jpg',
    ),
    'computer_laptop': ApplianceVisual(
      label: 'Ordinateur portable',
      icon: Icons.laptop_outlined,
      assetPath: 'assets/images/appliances/computer_laptop.jpg',
    ),
    'desktop_pc': ApplianceVisual(
      label: 'Ordinateur fixe',
      icon: Icons.computer_outlined,
      assetPath: 'assets/images/appliances/desktop_pc.jpg',
    ),
    'monitor_screen': ApplianceVisual(
      label: 'Écran / Moniteur',
      icon: Icons.monitor_outlined,
      assetPath: 'assets/images/appliances/monitor_screen.jpg',
    ),
    'gaming_console': ApplianceVisual(
      label: 'Console de jeux',
      icon: Icons.sports_esports_outlined,
      assetPath: 'assets/images/appliances/gaming_console.jpg',
    ),
    'audio_system': ApplianceVisual(
      label: 'Système audio / Enceinte',
      icon: Icons.speaker_outlined,
      assetPath: 'assets/images/appliances/audio_system.jpg',
    ),
    'printer_scanner': ApplianceVisual(
      label: 'Imprimante / Scanner',
      icon: Icons.print_outlined,
      assetPath: 'assets/images/appliances/printer_scanner.jpg',
    ),
    'charger': ApplianceVisual(
      label: 'Chargeur',
      icon: Icons.battery_charging_full,
      assetPath: 'assets/images/appliances/charger.jpg',
    ),

    // --- HYGIÈNE & BEAUTÉ ---
    'hair_dryer': ApplianceVisual(
      label: 'Sèche-cheveux',
      icon: Icons.air,
      assetPath: 'assets/images/appliances/hair_dryer.jpg',
    ),
    'hair_straightener': ApplianceVisual(
      label: 'Lisseur / Fer à boucler',
      icon: Icons.strikethrough_s_outlined,
      assetPath: 'assets/images/appliances/hair_straightener.jpg',
    ),
    'electric_shaver': ApplianceVisual(
      label: 'Rasoir / Tondeuse',
      icon: Icons.face_outlined,
      assetPath: 'assets/images/appliances/electric_shaver.jpg',
    ),
    'electric_toothbrush': ApplianceVisual(
      label: 'Brosse à dents électrique',
      icon: Icons.clean_hands_outlined,
      assetPath: 'assets/images/appliances/electric_toothbrush.jpg',
    ),

    // --- SÉCURITÉ & DOMOTIQUE ---
    'security_camera': ApplianceVisual(
      label: 'Caméra de surveillance',
      icon: Icons.videocam_outlined,
      assetPath: 'assets/images/appliances/security_camera.jpg',
    ),
    'alarm_system': ApplianceVisual(
      label: 'Système d\'alarme',
      icon: Icons.security_outlined,
      assetPath: 'assets/images/appliances/alarm_system.jpg',
    ),
    'smart_lock': ApplianceVisual(
      label: 'Serrure connectée',
      icon: Icons.lock_outlined,
      assetPath: 'assets/images/appliances/smart_lock.jpg',
    ),

    // --- INFRASTRUCTURE, EAU & ÉNERGIE ---
    'water_heater': ApplianceVisual(
      label: 'Chauffe-eau',
      icon: Icons.hot_tub_outlined,
      assetPath: 'assets/images/appliances/water_heater.jpg',
    ),
    'water_pump': ApplianceVisual(
      label: 'Pompe à eau',
      icon: Icons.water_outlined,
      assetPath: 'assets/images/appliances/water_pump.jpg',
    ),
    'light_bulb': ApplianceVisual(
      label: 'Éclairage',
      icon: Icons.lightbulb_outline,
      assetPath: 'assets/images/appliances/light_bulb.jpg',
    ),
    'voltage_regulator': ApplianceVisual(
      label: 'Régulateur de tension',
      icon: Icons.electric_meter_outlined,
      assetPath: 'assets/images/appliances/voltage_regulator.jpg',
    ),
    'ups_inverter': ApplianceVisual(
      label: 'Onduleur / Inverter',
      icon: Icons.power_outlined,
      assetPath: 'assets/images/appliances/ups_inverter.jpg',
    ),
    'solar_panel': ApplianceVisual(
      label: 'Panneau solaire',
      icon: Icons.wb_sunny_outlined,
      assetPath: 'assets/images/appliances/solar_panel.jpg',
    ),
    'ev_charger': ApplianceVisual(
      label: 'Borne de recharge véhicule',
      icon: Icons.ev_station_outlined,
      assetPath: 'assets/images/appliances/ev_charger.jpg',
    ),

    // --- OUTILLAGE & JARDIN ---
    'lawn_mower': ApplianceVisual(
      label: 'Tondeuse à gazon',
      icon: Icons.grass_outlined,
      assetPath: 'assets/images/appliances/lawn_mower.jpg',
    ),
    'power_tools': ApplianceVisual(
      label: 'Outillage électrique (Perceuse, etc.)',
      icon: Icons.build_outlined,
      assetPath: 'assets/images/appliances/power_tools.jpg',
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
