import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/water_intake_model.dart';

class AddWaterDialog extends StatefulWidget {
  final Function(WaterIntake) onAddWater;

  const AddWaterDialog({
    Key? key,
    required this.onAddWater,
  }) : super(key: key);

  @override
  State<AddWaterDialog> createState() => _AddWaterDialogState();
}

class _AddWaterDialogState extends State<AddWaterDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  double _sliderValue = 0.25;

  @override
  void initState() {
    super.initState();
    _amountController.text = _sliderValue.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateSliderFromTextfield() {
    if (_amountController.text.isNotEmpty) {
      try {
        double value = double.parse(_amountController.text);
        setState(() {
          _sliderValue = value.clamp(0.0, 2.0);
        });
      } catch (e) {
        // Invalid input, ignore
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Create a new water intake record
      final newWaterIntake = WaterIntake(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: _sliderValue,
        timestamp: DateTime.now(),
      );

      // Call the callback function
      widget.onAddWater(newWaterIntake);

      // Close the dialog
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.md,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Water',
                    style: AppTextStyles.headerMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.water.withOpacity(0.1),
                      borderRadius: AppBorderRadius.sm,
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: AppColors.water,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount (L)',
                        border: OutlineInputBorder(),
                        suffixText: 'L',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        try {
                          double amount = double.parse(value);
                          if (amount <= 0 || amount > 2) {
                            return 'Enter a value between 0 and 2';
                          }
                        } catch (e) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _updateSliderFromTextfield();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Text('0.0 L', style: AppTextStyles.bodySmall),
                  Expanded(
                    child: Slider(
                      value: _sliderValue,
                      min: 0.0,
                      max: 2.0,
                      divisions: 40, // 0.05L increments
                      activeColor: AppColors.water,
                      label: '${_sliderValue.toStringAsFixed(2)} L',
                      onChanged: (value) {
                        setState(() {
                          _sliderValue = value;
                          _amountController.text = value.toStringAsFixed(2);
                        });
                      },
                    ),
                  ),
                  const Text('2.0 L', style: AppTextStyles.bodySmall),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Quick water buttons
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [0.25, 0.5, 0.75, 1.0].map((amount) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _sliderValue = amount;
                        _amountController.text = amount.toStringAsFixed(2);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _sliderValue == amount ? AppColors.water : Colors.grey.shade200,
                      foregroundColor:
                          _sliderValue == amount ? Colors.white : AppColors.textDark,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                    child: Text('${amount.toStringAsFixed(2)} L'),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.water,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Water'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 