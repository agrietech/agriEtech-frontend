import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/validators.dart';
import '../../farms/providers/farms_provider.dart';
import '../models/sensor_models.dart';
import '../providers/sensor_provider.dart';

class RegisterSensorScreen extends ConsumerStatefulWidget {
  const RegisterSensorScreen({super.key});

  @override
  ConsumerState<RegisterSensorScreen> createState() =>
      _RegisterSensorScreenState();
}

class _RegisterSensorScreenState extends ConsumerState<RegisterSensorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hardwareIdController = TextEditingController();

  String? _selectedFarmId;
  String _selectedSensorType = SensorTypes.soilMoisture;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _hardwareIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final farmsAsync = ref.watch(farmsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Sensor'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Sensor Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sensor Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // Hardware ID
                    TextFormField(
                      controller: _hardwareIdController,
                      decoration: const InputDecoration(
                        labelText: 'Hardware ID',
                        prefixIcon: Icon(Icons.qr_code),
                        border: OutlineInputBorder(),
                        helperText: 'Unique identifier from the sensor device',
                      ),
                      validator: (value) => Validators.validateRequired(
                        value,
                        'Hardware ID',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sensor Type
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSensorType,
                      decoration: const InputDecoration(
                        labelText: 'Sensor Type',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: SensorTypes.all.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(
                                _getSensorIcon(type),
                                size: 20,
                                color: _getSensorColor(type),
                              ),
                              const SizedBox(width: 12),
                              Text(SensorTypes.getDisplayName(type)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedSensorType = value!);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Farm Selection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farm Location',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // Farm Dropdown
                    Builder(
                      builder: (context) {
                        if (farmsAsync.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (farmsAsync.error != null) {
                          return Text(
                            'Error loading farms: ${farmsAsync.error!.message}',
                            style: const TextStyle(color: Colors.red),
                          );
                        }
                        final farms = farmsAsync.farms;
                        if (farms.isEmpty) {
                          return Card(
                            color: Colors.orange[50],
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Colors.orange[700]),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'No farms available. Please add a farm first.',
                                      style: TextStyle(
                                        color: Colors.orange[900],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return DropdownButtonFormField<String>(
                          initialValue: _selectedFarmId,
                          decoration: const InputDecoration(
                            labelText: 'Select Farm',
                            prefixIcon: Icon(Icons.agriculture),
                            border: OutlineInputBorder(),
                          ),
                          items: farms.map((farm) {
                            return DropdownMenuItem(
                              value: farm.id,
                              child: Text(farm.farmName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedFarmId = value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a farm';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _registerSensor,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.sensors),
                label: Text(_isSubmitting ? 'Registering...' : 'Register Sensor'),
              ),
            ),

            const SizedBox(height: 16),

            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sensor Registration Tips',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('Ensure the hardware ID matches your device'),
                    _buildTip('Select the correct sensor type'),
                    _buildTip('Calibrate the sensor before deployment'),
                    _buildTip('Check battery level regularly'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registerSensor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final request = RegisterSensorRequest(
        farmId: _selectedFarmId!,
        hardwareId: _hardwareIdController.text.trim(),
        sensorType: _selectedSensorType,
        lastCalibration: DateTime.now().toIso8601String(),
      );

      // Register sensor
      final repository = ref.read(sensorRepositoryProvider);
      await repository.registerSensor(request);

      // Refresh sensor list
      ref.invalidate(sensorListProvider);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sensor registered successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Go back
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register sensor: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  IconData _getSensorIcon(String type) {
    switch (type) {
      case SensorTypes.soilMoisture:
        return Icons.water_drop;
      case SensorTypes.temperature:
        return Icons.thermostat;
      case SensorTypes.rainGauge:
        return Icons.shower;
      case SensorTypes.leafWetness:
        return Icons.grass;
      default:
        return Icons.sensors;
    }
  }

  Color _getSensorColor(String type) {
    switch (type) {
      case SensorTypes.soilMoisture:
        return Colors.blue;
      case SensorTypes.temperature:
        return Colors.orange;
      case SensorTypes.rainGauge:
        return Colors.indigo;
      case SensorTypes.leafWetness:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
