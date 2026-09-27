import 'package:sama_courant/features/appliances/domain/entities/usage_frequency.dart';

import '../../../../core/widgets/page_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/appliance.dart';
import '../../domain/providers/appliance_usecase_providers.dart';
import '../providers/appliances_provider.dart';

class ApplianceFormPage extends ConsumerStatefulWidget {
  final Appliance? appliance;

  const ApplianceFormPage({super.key, this.appliance});

  @override
  ConsumerState<ApplianceFormPage> createState() => _ApplianceFormPageState();
}

class _ApplianceFormPageState extends ConsumerState<ApplianceFormPage> {
  bool get _isEditMode => widget.appliance != null;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _powerController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  UsageFrequency _selectedUsageFrequency = UsageFrequency.daily;

  String? _selectedCategory;

  bool _isSaving = false;
  bool _isActive = true;

  double _usageDurationMinutesValue = 30;
  int _usageCountValue = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _powerController.dispose();
    _quantityController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  String _formatUsageDuration(double minutesValue) {
    final minutes = minutesValue.round();

    if (minutes <= 0) {
      return '0 min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '$minutes min';
    }

    if (remainingMinutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${remainingMinutes}m';
  }

  void _initializeForm() {
    final appliance = widget.appliance;

    if (appliance == null) {
      _usageDurationMinutesValue = 30;
      _usageCountValue = 1;
      _selectedUsageFrequency = UsageFrequency.daily;
      return;
    }

    _nameController.text = appliance.name;
    _selectedCategory = appliance.category;
    _powerController.text = appliance.powerWatts.toString();
    _quantityController.text = appliance.quantity.toString();

    if (appliance.usesNewUsageModel) {
      _usageDurationMinutesValue = appliance.usageDurationMinutes!.toDouble();

      _usageCountValue = appliance.usageCount!;

      _selectedUsageFrequency = appliance.usageFrequency!;
    } else {
      _usageDurationMinutesValue = 30;
      _usageCountValue = 1;
      _selectedUsageFrequency = UsageFrequency.daily;
    }

    _isActive = appliance.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: pageAppBar(
        context: context,

        title: _isEditMode ? 'Modifier un appareil' : 'Ajouter un appareil',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(context),

            const SizedBox(height: 12),

            _buildSection(
              context,
              icon: Icons.electrical_services,
              title: 'Identification',
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nom',
                    hint: 'Ex. Frigo',
                    icon: Icons.devices_other,
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryField(),
                ],
              ),
            ),

            const SizedBox(height: 12),

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
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _quantityController,
                    label: 'Quantité',
                    hint: 'Ex. 1',
                    icon: Icons.format_list_numbered,
                    keyboardType: TextInputType.number,
                    validator: _validateQuantity,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _buildSection(
              context,
              icon: Icons.schedule,
              title: 'Utilisation',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Durée', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatUsageDuration(_usageDurationMinutesValue),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 9,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 18,
                            ),
                          ),
                          child: Slider(
                            value: _usageDurationMinutesValue,
                            min: 5,
                            max: 1440,
                            divisions: 96, // pas de 15 minutes
                            label: _formatUsageDuration(
                              _usageDurationMinutesValue,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _usageDurationMinutesValue = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Nombre de fois',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.repeat,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$_usageCountValue fois',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Slider(
                          value: _usageCountValue.toDouble(),
                          min: 1,
                          max: 30,
                          divisions: 29,
                          label: '$_usageCountValue',
                          onChanged: (value) {
                            setState(() {
                              _usageCountValue = value.round();
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<UsageFrequency>(
                    initialValue: _selectedUsageFrequency,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Fréquence',
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: UsageFrequency.daily,
                        child: Text('Par jour'),
                      ),
                      DropdownMenuItem(
                        value: UsageFrequency.weekly,
                        child: Text('Par semaine'),
                      ),
                      DropdownMenuItem(
                        value: UsageFrequency.monthly,
                        child: Text('Par mois'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _selectedUsageFrequency = value;
                      });
                    },
                  ),

                  const SizedBox(height: 8),

                  Text(
                    switch (_selectedUsageFrequency) {
                      UsageFrequency.daily =>
                        'Combien de fois utilisez-vous cet appareil chaque jour ?',
                      UsageFrequency.weekly =>
                        'Combien de fois utilisez-vous cet appareil chaque semaine ?',
                      UsageFrequency.monthly =>
                        'Combien de fois utilisez-vous cet appareil chaque mois ?',
                    },
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (_isEditMode) ...[
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                  title: const Text(
                    'Appareil actif',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _isActive
                        ? 'Cet appareil est pris en compte dans votre consommation.'
                        : 'Cet appareil est exclu de votre consommation.',
                  ),
                  secondary: Icon(
                    _isActive
                        ? Icons.check_circle_outline
                        : Icons.pause_circle_outline,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: _isSaving ? null : _onSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  _isSaving ? 'Enregistrement...' : 'Enregistrer',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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

    if (name.length > 100) {
      return 'Le nom ne doit pas dépasser 100 caractères.';
    }

    return null;
  }

  String? _validatePower(String? value) {
    final power = double.tryParse(value?.trim() ?? '');

    if (power == null) {
      return 'La puissance est requise.';
    }

    if (!power.isFinite) {
      return 'Veuillez saisir une puissance valide.';
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

  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez sélectionner une catégorie.';
    }

    return null;
  }

  Appliance _buildAppliance() {
    final now = DateTime.now();
    final existingAppliance = widget.appliance;

    return Appliance(
      id: existingAppliance?.id,
      name: _nameController.text.trim(),
      category: _selectedCategory!,
      powerWatts: double.parse(_powerController.text.trim()),
      quantity: int.parse(_quantityController.text.trim()),

      // Champs legacy obligatoires pour le moment.
      hoursPerDay: existingAppliance?.hoursPerDay ?? 0,
      daysPerMonth: existingAppliance?.daysPerMonth ?? 30,

      // Nouveau modèle d'utilisation.
      usageDurationMinutes: _usageDurationMinutesValue.round(),
      usageCount: _usageCountValue,
      usageFrequency: _selectedUsageFrequency,

      isActive: _isActive,
      createdAt: existingAppliance?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> _onSave() async {
    if (_isSaving) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final appliance = _buildAppliance();

      if (!appliance.monthlyConsumptionKwh.isFinite) {
        throw const FormatException('Consommation hors limites numériques.');
      }

      if (_isEditMode) {
        final updateAppliance = ref.read(updateApplianceProvider);

        final updated = await updateAppliance(appliance);

        if (!updated) {
          throw Exception('Impossible de modifier cet appareil.');
        }

        debugPrint('Appliance modifié avec succès.');
        debugPrint('ID: ${appliance.id}');
      } else {
        final createAppliance = ref.read(createApplianceProvider);

        final id = await createAppliance(appliance);

        debugPrint('Appliance enregistré avec succès.');
        debugPrint('ID: $id');
      }

      if (!mounted) {
        return;
      }

      await ref.read(appliancesProvider.notifier).loadAppliances();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Appareil modifié avec succès.'
                : 'Appareil enregistré avec succès.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.pop();
    } catch (error, stackTrace) {
      debugPrint('Erreur lors de l’enregistrement : $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Impossible de modifier l’appareil. Veuillez réessayer.'
                : 'Impossible d’enregistrer l’appareil. Veuillez réessayer.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bolt, color: colorScheme.onPrimary, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode ? 'Modifier l’appareil' : 'Nouvel appareil',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditMode
                      ? 'Mettez à jour les informations de cet appareil.'
                      : 'Ajoutez un appareil pour suivre sa consommation.',
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
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
        hintMaxLines: 2,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(icon),
        suffixText: suffixText,
        errorMaxLines: 4,
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
      isExpanded: true,
      isDense: false,
      itemHeight: null,
      initialValue: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Catégorie',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        errorMaxLines: 4,
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
