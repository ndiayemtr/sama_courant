import '../entities/appliance_power_estimate.dart';

const Map<String, AppliancePowerEstimate> appliancePowerEstimates = {
  'refrigerator': AppliancePowerEstimate(
    typicalWatts: 150,
    minWatts: 80,
    maxWatts: 500,
  ),
  'freezer': AppliancePowerEstimate(
    typicalWatts: 200,
    minWatts: 100,
    maxWatts: 500,
  ),
  'air_conditioner': AppliancePowerEstimate(
    typicalWatts: 1200,
    minWatts: 500,
    maxWatts: 4500,
  ),
  'fan': AppliancePowerEstimate(typicalWatts: 75, minWatts: 40, maxWatts: 250),
  'dehumidifier_humidifier': AppliancePowerEstimate(
    typicalWatts: 500,
    minWatts: 20,
    maxWatts: 800,
  ),

  'iron': AppliancePowerEstimate(
    typicalWatts: 1400,
    minWatts: 1000,
    maxWatts: 1800,
  ),
  'washing_machine': AppliancePowerEstimate(
    typicalWatts: 700,
    minWatts: 350,
    maxWatts: 1300,
  ),
  'dryer': AppliancePowerEstimate(
    typicalWatts: 3000,
    minWatts: 1800,
    maxWatts: 5000,
  ),
  'vacuum_cleaner': AppliancePowerEstimate(
    typicalWatts: 1000,
    minWatts: 600,
    maxWatts: 1400,
  ),

  'microwave': AppliancePowerEstimate(
    typicalWatts: 1000,
    minWatts: 750,
    maxWatts: 1500,
  ),
  'electric_oven': AppliancePowerEstimate(
    typicalWatts: 2000,
    minWatts: 1200,
    maxWatts: 3200,
  ),
  'electric_cooktop': AppliancePowerEstimate(
    typicalWatts: 1500,
    minWatts: 1000,
    maxWatts: 3000,
  ),
  'rice_cooker': AppliancePowerEstimate(
    typicalWatts: 700,
    minWatts: 300,
    maxWatts: 1200,
  ),
  'air_fryer': AppliancePowerEstimate(
    typicalWatts: 1500,
    minWatts: 800,
    maxWatts: 2000,
  ),
  'kettle': AppliancePowerEstimate(
    typicalWatts: 1500,
    minWatts: 1000,
    maxWatts: 2200,
  ),
  'coffee_maker': AppliancePowerEstimate(
    typicalWatts: 900,
    minWatts: 600,
    maxWatts: 1500,
  ),
  'toaster': AppliancePowerEstimate(
    typicalWatts: 1000,
    minWatts: 700,
    maxWatts: 1500,
  ),
  'blender_mixer': AppliancePowerEstimate(
    typicalWatts: 400,
    minWatts: 100,
    maxWatts: 1200,
  ),

  'television': AppliancePowerEstimate(
    typicalWatts: 100,
    minWatts: 30,
    maxWatts: 330,
  ),
  'decoder_box': AppliancePowerEstimate(
    typicalWatts: 30,
    minWatts: 10,
    maxWatts: 60,
  ),
  'router_modem': AppliancePowerEstimate(
    typicalWatts: 15,
    minWatts: 5,
    maxWatts: 30,
  ),
  'computer_laptop': AppliancePowerEstimate(
    typicalWatts: 100,
    minWatts: 30,
    maxWatts: 500,
  ),
  'monitor_screen': AppliancePowerEstimate(
    typicalWatts: 60,
    minWatts: 20,
    maxWatts: 150,
  ),
  'gaming_console': AppliancePowerEstimate(
    typicalWatts: 150,
    minWatts: 20,
    maxWatts: 250,
  ),
  'audio_system': AppliancePowerEstimate(
    typicalWatts: 100,
    minWatts: 20,
    maxWatts: 500,
  ),
  'charger': AppliancePowerEstimate(
    typicalWatts: 20,
    minWatts: 5,
    maxWatts: 100,
  ),

  'water_heater': AppliancePowerEstimate(
    typicalWatts: 3000,
    minWatts: 1000,
    maxWatts: 5500,
  ),
  'water_pump': AppliancePowerEstimate(
    typicalWatts: 750,
    minWatts: 250,
    maxWatts: 2200,
  ),
  'hair_dryer': AppliancePowerEstimate(
    typicalWatts: 1500,
    minWatts: 1000,
    maxWatts: 2000,
  ),

  'light_bulb': AppliancePowerEstimate(
    typicalWatts: 10,
    minWatts: 3,
    maxWatts: 100,
  ),
  'voltage_regulator': AppliancePowerEstimate(
    typicalWatts: 20,
    minWatts: 5,
    maxWatts: 100,
  ),
  'ups_inverter': AppliancePowerEstimate(
    typicalWatts: 50,
    minWatts: 10,
    maxWatts: 300,
  ),
};
