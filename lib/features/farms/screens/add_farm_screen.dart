import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/models/farm_model.dart';
import '../providers/farms_provider.dart';
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
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationError.serviceDisabled();
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationError.permissionDenied();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationError.permissionDenied();
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location captured successfully'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } on AppError catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          LocationError.timeout(),
        );
      }
    } finally {
      setState(() => _isGettingLocation = false);
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
        final request = CreateFarmRequest(
          farmName: _nameController.text.trim(),
          primaryCrop: _selectedCrop!,
          areaHectares: double.parse(_sizeController.text),
          latitude: _latitude!,
          longitude: _longitude!,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Farm'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Farm name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Farm Name',
                  prefixIcon: const Icon(Icons.agriculture),
                  hintText: 'e.g., North Field, Family Farm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.required(value, 'Farm name'),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Crop type dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCrop,
                decoration: InputDecoration(
                  labelText: 'Primary Crop',
                  prefixIcon: const Icon(Icons.grass),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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

              // Farm size
              TextFormField(
                controller: _sizeController,
                decoration: InputDecoration(
                  labelText: 'Farm Size',
                  prefixIcon: const Icon(Icons.crop_square),
                  suffixText: 'hectares',
                  hintText: '0.5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: Validators.farmArea,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Soil type dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedSoilType,
                decoration: InputDecoration(
                  labelText: 'Soil Type (Optional)',
                  prefixIcon: const Icon(Icons.landscape),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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

              // Irrigation type dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedIrrigation,
                decoration: InputDecoration(
                  labelText: 'Irrigation Type (Optional)',
                  prefixIcon: const Icon(Icons.water_drop),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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

              // Additional crops
              TextFormField(
                controller: _additionalCropsController,
                decoration: InputDecoration(
                  labelText: 'Additional Crops (Optional)',
                  prefixIcon: const Icon(Icons.eco),
                  hintText: 'e.g., Vegetables, Beans',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                maxLines: 2,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

              // Location card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: theme.primaryColor,
                          ),
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
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Location Captured',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[900],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Lat: ${_latitude!.toStringAsFixed(6)}, '
                                      'Lng: ${_longitude!.toStringAsFixed(6)}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Please capture the farm location using GPS',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ElevatedButton.icon(
                        onPressed: _isGettingLocation || _isLoading
                            ? null
                            : _getCurrentLocation,
                        icon: _isGettingLocation
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.my_location),
                        label: Text(
                          _latitude == null ? 'Capture Location' : 'Update Location',
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveFarm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Farm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
