import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/models/farm_model.dart';
import '../providers/farms_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/error/app_error.dart';

class AddFarmScreen extends ConsumerStatefulWidget {
  const AddFarmScreen({super.key});

  @override
  ConsumerState<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends ConsumerState<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sizeController = TextEditingController();
  final _additionalCropsController = TextEditingController();
  
  String? _selectedCrop;
  String? _selectedSoilType;
  String? _selectedIrrigation;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  bool _isGettingLocation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _additionalCropsController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied in settings. Please enable GPS permissions.'),
              backgroundColor: Color(0xFFD32F2F),
            ),
          );
        }
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        setState(() {
          _latitude = position!.latitude;
          _longitude = position.longitude;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('GPS Location captured: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}'),
              backgroundColor: const Color(0xFF2E7D32),
            ),
          );
        }
      } else {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('GPS Location service is turned off on your device. Please enable Location/GPS.'),
              backgroundColor: Color(0xFFF57C00),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to acquire GPS lock. Please check your device location settings.'),
              backgroundColor: Color(0xFFD32F2F),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GPS capture error: ${e.toString()}'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  Future<void> _saveFarm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCrop == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a crop type'),
            backgroundColor: Color(0xFFF57C00),
          ),
        );
        return;
      }

      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please capture farm location'),
            backgroundColor: Color(0xFFF57C00),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final user = ref.read(authProvider).user;
        final woredaId = user?.woredaId ?? user?.woreda?.id ?? 'woreda_adama_01';
        final request = CreateFarmRequest(
          farmName: _nameController.text.trim(),
          primaryCrop: _selectedCrop!,
          areaHectares: double.parse(_sizeController.text),
          latitude: _latitude!,
          longitude: _longitude!,
          woredaId: woredaId,
          soilType: _selectedSoilType,
          irrigationType: _selectedIrrigation,
          additionalCrops: _additionalCropsController.text.trim().isEmpty
              ? null
              : _additionalCropsController.text.trim(),
        );

        await ref.read(farmsProvider.notifier).createFarm(request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Farm added successfully'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
          context.pop();
        }
      } on AppError catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, e);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Farm', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Farm Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Farm Name *',
                  prefixIcon: const Icon(Icons.agriculture),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.required(value, 'Farm name'),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Primary Crop Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCrop,
                decoration: InputDecoration(
                  labelText: 'Primary Crop *',
                  prefixIcon: const Icon(Icons.grass),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
                ),
                items: CropTypes.common.map((crop) {
                  return DropdownMenuItem(
                    value: crop,
                    child: Text(crop),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _selectedCrop = value);
                      },
                validator: (value) {
                  if (value == null) return 'Please select a crop type';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Farm Size
              TextFormField(
                controller: _sizeController,
                decoration: InputDecoration(
                  labelText: 'Farm Size *',
                  prefixIcon: const Icon(Icons.crop_square),
                  suffixText: 'hectares',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: Validators.farmArea,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Soil Type Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedSoilType,
                decoration: InputDecoration(
                  labelText: 'Soil Type (Optional)',
                  prefixIcon: const Icon(Icons.landscape),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
                ),
                items: SoilTypes.displayNames.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _selectedSoilType = value);
                      },
              ),
              const SizedBox(height: 16),

              // Irrigation Type Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedIrrigation,
                decoration: InputDecoration(
                  labelText: 'Irrigation Type (Optional)',
                  prefixIcon: const Icon(Icons.water_drop),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
                ),
                items: IrrigationTypes.displayNames.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _selectedIrrigation = value);
                      },
              ),
              const SizedBox(height: 16),

              // Additional Crops
              TextFormField(
                controller: _additionalCropsController,
                decoration: InputDecoration(
                  labelText: 'Additional Crops (Optional)',
                  prefixIcon: const Icon(Icons.eco),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
                ),
                textCapitalization: TextCapitalization.words,
                maxLines: 1,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20),

              // Location Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: isDark ? const Color(0xFF263E26) : Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: theme.primaryColor, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Farm Location',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_latitude != null && _longitude != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GPS Coordinates Captured',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Lat: ${_latitude!.toStringAsFixed(5)}, Lng: ${_longitude!.toStringAsFixed(5)}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ElevatedButton.icon(
                        onPressed: (_isLoading || _isGettingLocation) ? null : _getCurrentLocation,
                        icon: _isGettingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location, size: 18),
                        label: Text(
                          _latitude != null ? 'Recapture Location' : 'Capture Current Location',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
                          foregroundColor: theme.primaryColor,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Farm Button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveFarm,
                  icon: const Icon(Icons.save, size: 20),
                  label: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save Farm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
