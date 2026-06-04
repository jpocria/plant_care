import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;
import 'dart:typed_data';
import '../../../core/services/care_plan_service.dart';
import '../../../data/models/care_plan_model.dart';
import '../../../data/repositories/plant_repository.dart';
import '../../../data/models/plant_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  PlantType _selectedType = PlantType.other;
  double _targetHumidity = 60.0;
  double _targetTemperature = 22.0;
  int _wateringFrequency = 3;
  XFile? _selectedImage;
  Uint8List? _imageBytes; // para preview no Web
  String? _selectedVegetableId;
  List<CarePlanModel> _vegetables = [];
  bool _loadingVeggies = true;

  @override
  void initState() {
    super.initState();
    CarePlanService().loadAll().then((list) {
      if (mounted) {
        setState(() {
          _vegetables = list;
          _loadingVeggies = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                    final bytes = kIsWeb ? await image.readAsBytes() : null;
                    if (mounted) {
                      setState(() {
                        _selectedImage = image;
                        _imageBytes = bytes;
                      });
                    }
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
                    final bytes = kIsWeb ? await image.readAsBytes() : null;
                    if (mounted) {
                      setState(() {
                        _selectedImage = image;
                        _imageBytes = bytes;
                      });
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final plantRepo = context.read<PlantRepository>();
    final success = await plantRepo.addPlant(
      name: _nameController.text,
      type: _selectedType,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      targetHumidity: _targetHumidity,
      targetTemperature: _targetTemperature,
      wateringFrequencyDays: _wateringFrequency,
      location: _locationController.text.isEmpty
          ? null
          : _locationController.text,
      vegetableId: _selectedVegetableId,
      imageFile: _selectedImage,
    );

    if (success && mounted) {
      context.go('/home');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Planta adicionada com sucesso! 🌱'),
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

    return LoadingOverlay(
      isLoading: plantRepo.isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.go('/home'),
          ),
          title: const Text('Nova Planta'),
          actions: [
            TextButton(
              onPressed: _save,
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
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withAlpha((0.08 * 255).round()),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppTheme.primaryGreen.withAlpha((0.3 * 255).round()),
                          width: 2,
                        ),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: kIsWeb
                                  ? Image.memory(_imageBytes!,
                                      fit: BoxFit.cover)
                                  : Image.file(
                                      File(_selectedImage!.path),
                                      fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 36,
                                    color: AppTheme.primaryGreen
                                        .withAlpha((0.6 * 255).round())),
                                const SizedBox(height: 4),
                                Text(
                                  'Adicionar foto',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.primaryGreen
                                        .withAlpha((0.6 * 255).round()),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _SectionTitle(title: 'Informações básicas'),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _nameController,
                  label: 'Nome da planta *',
                  hint: 'Ex: Alface, Manjericão...',
                  prefixIcon: Icons.local_florist_outlined,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Digite o nome da planta';
                    }
                    if (v.trim().length < 2) {
                      return 'Nome muito curto';
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
                  onChanged: (v) => setState(() => _selectedType = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedVegetableId,
                  decoration: const InputDecoration(
                    labelText: 'Hortaliça base (plano de cuidados)',
                    prefixIcon:
                        Icon(Icons.eco_outlined, size: 20),
                    helperText: 'Opcional: gera um plano completo de cuidados',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Nenhuma'),
                    ),
                    ..._vegetables.map((v) => DropdownMenuItem<String>(
                          value: v.id,
                          child: Text('${v.emoji} ${v.name}'),
                        )),
                  ],
                  onChanged: _loadingVeggies
                      ? null
                      : (v) => setState(() => _selectedVegetableId = v),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Descrição (opcional)',
                  hint: 'Observações sobre esta planta...',
                  prefixIcon: Icons.notes_outlined,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _locationController,
                  label: 'Localização (opcional)',
                  hint: 'Ex: Varanda, Janela da sala...',
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
                  label: 'Adicionar planta 🌱',
                  onPressed: _save,
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
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
    );
  }
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