import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/repositories/plant_repository.dart';
import '../../../data/models/plant_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

class EditPlantScreen extends StatefulWidget {
  final String plantId;
  const EditPlantScreen({super.key, required this.plantId});

  @override
  State<EditPlantScreen> createState() => _EditPlantScreenState();
}

class _EditPlantScreenState extends State<EditPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  PlantType _selectedType = PlantType.other;
  double _targetHumidity = 60.0;
  double _targetTemperature = 22.0;
  int _wateringFrequency = 3;
  XFile? _newImage;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _initFromPlant(PlantModel plant) {
    if (_initialized) return;
    _nameController.text = plant.name;
    _descriptionController.text = plant.description ?? '';
    _locationController.text = plant.location ?? '';
    _selectedType = plant.type;
    _targetHumidity = plant.targetHumidity;
    _targetTemperature = plant.targetTemperature;
    _wateringFrequency = plant.wateringFrequencyDays;
    _initialized = true;
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Câmera',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final image = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1024,
                      maxHeight: 1024,
                      imageQuality: 85);
                  if (image != null) {
                    setState(() => _newImage = image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galeria',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1024,
                      maxHeight: 1024,
                      imageQuality: 85);
                  if (image != null) {
                    setState(() => _newImage = image);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(PlantModel original) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final plantRepo = context.read<PlantRepository>();
    final updates = <String, dynamic>{
      'name': _nameController.text.trim(),
      'type': _selectedType.name,
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'location': _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      'targetHumidity': _targetHumidity,
      'targetTemperature': _targetTemperature,
      'wateringFrequencyDays': _wateringFrequency,
    };

    final success = await plantRepo.updatePlant(
      plantId: widget.plantId,
      updates: updates,
      newImageFile: _newImage,
    );

    if (success && mounted) {
      context.go('/plant/${widget.plantId}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Planta atualizada! ✅'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(plantRepo.error ?? 'Erro ao salvar'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final plantRepo = context.watch<PlantRepository>();
    final plant = plantRepo.findPlantById(widget.plantId);

    if (plant == null) {
      return Scaffold(
          appBar: AppBar(),
          body:
              const Center(child: Text('Planta não encontrada')));
    }

    _initFromPlant(plant);

    return LoadingOverlay(
      isLoading: plantRepo.isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.go('/plant/${widget.plantId}'),
          ),
          title: const Text('Editar Planta'),
          actions: [
            TextButton(
              onPressed: () => _save(plant),
              child: const Text('Salvar',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: AppTheme.primaryGreen
                                    .withAlpha((0.3 * 255).round()),
                                width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: _newImage != null
                                ? Image.file(File(_newImage!.path),
                                    fit: BoxFit.cover)
                                : plant.imageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: plant.imageUrl!,
                                        fit: BoxFit.cover)
                                    : Container(
                                        color: AppTheme.primaryGreen
                                            .withAlpha((0.08 * 255).round()),
                                        child: const Center(
                                            child: Text('🪴',
                                                style: TextStyle(
                                                    fontSize: 48))),
                                      ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.edit_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _SectionTitle(title: 'Informações básicas'),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _nameController,
                  label: 'Nome da planta *',
                  prefixIcon: Icons.local_florist_outlined,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Digite o nome da planta';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PlantType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de planta',
                    prefixIcon:
                        Icon(Icons.category_outlined, size: 20),
                  ),
                  items: PlantType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedType = v!),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Descrição (opcional)',
                  prefixIcon: Icons.notes_outlined,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _locationController,
                  label: 'Localização (opcional)',
                  prefixIcon: Icons.location_on_outlined,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 28),
                _SectionTitle(title: 'Configurações de cuidado'),
                const SizedBox(height: 16),
                _SliderCard(
                  title: 'Frequência de rega',
                  subtitle: 'A cada $_wateringFrequency dia(s)',
                  icon: '💧',
                  value: _wateringFrequency.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  onChanged: (v) =>
                      setState(() => _wateringFrequency = v.round()),
                ),
                const SizedBox(height: 14),
                _SliderCard(
                  title: 'Umidade alvo',
                  subtitle: '${_targetHumidity.round()}%',
                  icon: '🌡️',
                  value: _targetHumidity,
                  min: 10,
                  max: 100,
                  divisions: 18,
                  onChanged: (v) =>
                      setState(() => _targetHumidity = v),
                ),
                const SizedBox(height: 14),
                _SliderCard(
                  title: 'Temperatura ideal',
                  subtitle: '${_targetTemperature.round()}°C',
                  icon: '🌡️',
                  value: _targetTemperature,
                  min: 5,
                  max: 40,
                  divisions: 35,
                  onChanged: (v) =>
                      setState(() => _targetTemperature = v),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  label: 'Salvar alterações',
                  onPressed: () => _save(plant),
                  isFullWidth: true,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800, letterSpacing: -0.2),
      );
}

class _SliderCard extends StatelessWidget {
  final String title, subtitle, icon;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(subtitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGreen)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppTheme.primaryGreen,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}