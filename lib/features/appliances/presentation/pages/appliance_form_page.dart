import 'package:flutter/material.dart';

import '../../domain/entities/appliance.dart';

class ApplianceFormPage extends StatefulWidget {
  const ApplianceFormPage({super.key});

  @override
  State<ApplianceFormPage> createState() => _ApplianceFormPageState();
}

class _ApplianceFormPageState extends State<ApplianceFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _powerController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _hoursPerDayController = TextEditingController();
  final _daysPerMonthController = TextEditingController(text: '30');

  String? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _powerController.dispose();
    _quantityController.dispose();
    _hoursPerDayController.dispose();
    _daysPerMonthController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un appareil')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _buildHeader(context),

            const SizedBox(height: 24),

            _buildSection(
              context,
              icon: Icons.electrical_services,
              title: 'Identification',
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nom de l’appareil',
                    hint: 'Ex. Réfrigérateur',
                    icon: Icons.devices_other,
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryField(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildSection(
              context,
              icon: Icons.bolt,
              title: 'Consommation',
              child: Column(
                children: [
                  _buildTextField(
                    controller: _powerController,
                    label: 'Puissance',
                    hint: 'Ex. 150',
                    icon: Icons.power,
                    suffixText: 'W',
                    keyboardType: TextInputType.number,
                    validator: _validatePower,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _quantityController,
                    label: 'Quantité',
                    hint: 'Ex. 1',
                    icon: Icons.format_list_numbered,
                    suffixText: 'appareil(s)',
                    keyboardType: TextInputType.number,
                    validator: _validateQuantity,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildSection(
              context,
              icon: Icons.schedule,
              title: 'Utilisation',
              child: Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _hoursPerDayController,
                      label: 'Heures / jour',
                      hint: 'Ex. 8',
                      icon: Icons.access_time,
                      suffixText: 'h',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _validateHoursPerDay,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _daysPerMonthController,
                      label: 'Jours / mois',
                      hint: 'Ex. 30',
                      icon: Icons.calendar_month,
                      suffixText: 'j',
                      keyboardType: TextInputType.number,
                      validator: _validateDaysPerMonth,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _onSave,
              icon: const Icon(Icons.save_outlined),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Enregistrer l’appareil',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Vous pourrez modifier ces informations plus tard.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Le nom de l’appareil est requis.';
    }

    if (name.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères.';
    }

    return null;
  }

  String? _validatePower(String? value) {
    final power = double.tryParse(value?.trim() ?? '');

    if (power == null) {
      return 'La puissance est requise.';
    }

    if (power <= 0) {
      return 'La puissance doit être supérieure à 0 W.';
    }

    return null;
  }

  String? _validateQuantity(String? value) {
    final quantity = int.tryParse(value?.trim() ?? '');

    if (quantity == null) {
      return 'La quantité est requise.';
    }

    if (quantity < 1) {
      return 'La quantité doit être au moins égale à 1.';
    }

    return null;
  }

  String? _validateHoursPerDay(String? value) {
    final hours = double.tryParse(value?.trim() ?? '');

    if (hours == null) {
      return 'Les heures d’utilisation sont requises.';
    }

    if (hours <= 0 || hours > 24) {
      return 'Les heures doivent être comprises entre 0 et 24.';
    }

    return null;
  }

  String? _validateDaysPerMonth(String? value) {
    final days = int.tryParse(value?.trim() ?? '');

    if (days == null) {
      return 'Le nombre de jours est requis.';
    }

    if (days < 1 || days > 31) {
      return 'Les jours doivent être compris entre 1 et 31.';
    }

    return null;
  }

  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez sélectionner une catégorie.';
    }

    return null;
  }

  Appliance _buildAppliance() {
    final now = DateTime.now();

    return Appliance(
      name: _nameController.text.trim(),
      category: _selectedCategory!,
      powerWatts: double.parse(_powerController.text.trim()),
      quantity: int.parse(_quantityController.text.trim()),
      hoursPerDay: double.parse(_hoursPerDayController.text.trim()),
      daysPerMonth: int.parse(_daysPerMonthController.text.trim()),
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final appliance = _buildAppliance();

    debugPrint('Appliance créé :');
    debugPrint('Nom: ${appliance.name}');
    debugPrint('Catégorie: ${appliance.category}');
    debugPrint('Puissance: ${appliance.powerWatts} W');
    debugPrint('Quantité: ${appliance.quantity}');
    debugPrint('Heures/jour: ${appliance.hoursPerDay}');
    debugPrint('Jours/mois: ${appliance.daysPerMonth}');
    debugPrint('Actif: ${appliance.isActive}');
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bolt, color: colorScheme.onPrimary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nouvel appareil',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ajoutez un appareil pour suivre sa consommation.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 22, color: colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? suffixText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixText: suffixText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCategoryField() {
    const categories = [
      'Cuisine',
      'Salon',
      'Chambre',
      'Salle de bain',
      'Bureau',
      'Éclairage',
      'Autre',
    ];

    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Catégorie',
        prefixIcon: Icon(Icons.category_outlined),
        border: OutlineInputBorder(),
      ),
      items: categories
          .map(
            (category) => DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      validator: _validateCategory,
    );
  }
}
