import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/log_item.dart';
import '../services/logs_notifier.dart';
import '../services/firestore_logs_service.dart';

class FoodDetailsWidget extends ConsumerStatefulWidget {
  final LogItem logItem;

  const FoodDetailsWidget({
    Key? key,
    required this.logItem,
  }) : super(key: key);

  @override
  _FoodDetailsWidgetState createState() => _FoodDetailsWidgetState();
}

class _FoodDetailsWidgetState extends ConsumerState<FoodDetailsWidget> {
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _weightController;
  late List<TextEditingController> _macroControllers;
  double _originalWeight = 100.0;
  bool _isAdjusting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.logItem.name);
    _caloriesController = TextEditingController(text: widget.logItem.calories.toString());

    // Initialize weight controller
    _originalWeight = widget.logItem.baseWeight ?? 100.0;
    _weightController = TextEditingController(
        text: (widget.logItem.weight ?? _originalWeight).toString()
    );

    // Initialize macro controllers
    _macroControllers = widget.logItem.macros?.map((macro) =>
        TextEditingController(text: macro.value.toString())
    ).toList() ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _weightController.dispose();
    for (var controller in _macroControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Food Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            // Name Input
            _buildTextField(
              controller: _nameController,
              label: 'Food Name',
              icon: Icons.restaurant,
            ),

            const SizedBox(height: 16),

            // Weight Input with slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _weightController,
                  label: 'Weight',
                  icon: Icons.scale,
                  suffix: 'g',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: (value) {
                    if (!_isAdjusting) {
                      setState(() {
                        _updateMacrosBasedOnWeight();
                      });
                    }
                  },
                ),

                // Weight slider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        '0g',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.orange,
                            inactiveTrackColor: Colors.orange.withOpacity(0.2),
                            thumbColor: Colors.orange,
                            trackHeight: 4.0,
                          ),
                          child: Slider(
                            min: 0,
                            max: _originalWeight * 3, // Allow up to 3x the original weight
                            value: double.tryParse(_weightController.text) ?? _originalWeight,
                            onChanged: (value) {
                              _isAdjusting = true;
                              setState(() {
                                _weightController.text = value.toStringAsFixed(1);
                                _updateMacrosBasedOnWeight();
                              });
                              _isAdjusting = false;
                            },
                          ),
                        ),
                      ),
                      Text(
                        '${(_originalWeight * 3).toStringAsFixed(0)}g',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Calories Input
            _buildTextField(
              controller: _caloriesController,
              label: 'Calories',
              icon: Icons.local_fire_department,
              iconColor: Colors.orange,
              suffix: 'kcal',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 24),

            // Macros Title
            if (widget.logItem.macros != null && widget.logItem.macros!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  'Macronutrients',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Macros Inputs
            if (widget.logItem.macros != null)
              ...widget.logItem.macros!.asMap().entries.map((entry) {
                final index = entry.key;
                final macro = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildTextField(
                    controller: _macroControllers[index],
                    label: _getMacroLabel(macro.icon),
                    icon: _getMacroIcon(macro.icon),
                    iconColor: _getMacroColor(macro.icon),
                    suffix: 'g',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                );
              }).toList(),

            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveLogItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Save Changes',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Color iconColor = Colors.black54,
    String? suffix,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey.shade700),
          prefixIcon: Icon(icon, color: iconColor),
          suffixText: suffix,
          suffixStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _updateMacrosBasedOnWeight() {
    if (widget.logItem.baseWeight == null && _originalWeight <= 0) return;

    double currentWeight = double.tryParse(_weightController.text) ?? _originalWeight;
    double baseWeight = widget.logItem.baseWeight ?? _originalWeight;
    double scaleFactor = currentWeight / baseWeight;

    // Update calories
    int newCalories = (widget.logItem.calories * scaleFactor).round();
    _caloriesController.text = newCalories.toString();

    // Update macros
    for (int i = 0; i < _macroControllers.length; i++) {
      int originalMacroValue = widget.logItem.macros![i].value;
      int newMacroValue = (originalMacroValue * scaleFactor).round();
      _macroControllers[i].text = newMacroValue.toString();
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this food item?', style: GoogleFonts.poppins()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteLogItem();
            },
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _saveLogItem() {
    // Create an updated LogItem
    final updatedLogItem = LogItem(
      name: _nameController.text,
      calories: int.parse(_caloriesController.text),
      timestamp: widget.logItem.timestamp,
      type: widget.logItem.type,
      macros: widget.logItem.macros?.asMap().entries.map((entry) {
        final index = entry.key;
        final macro = entry.value;
        return MacroDetail(
          icon: macro.icon,
          value: int.parse(_macroControllers[index].text),
        );
      }).toList(),
      weight: double.tryParse(_weightController.text),
      baseWeight: widget.logItem.baseWeight ?? _originalWeight,
    );

    if (updatedLogItem != widget.logItem) {
      ref.read(firebaseLogsServiceProvider).deleteLogItem(widget.logItem);
      ref.read(firebaseLogsServiceProvider).addLogItem(updatedLogItem);
      ref.read(logsProvider.notifier).state = [
        ...ref.read(logsProvider.notifier).state.where((log) => log != widget.logItem),
        updatedLogItem
      ];
    }

    Navigator.of(context).pop();
  }

  void _deleteLogItem() {
    // Remove the log item from Firebase and local state
    ref.read(firebaseLogsServiceProvider).deleteLogItem(widget.logItem);
    ref.read(logsProvider.notifier).state =
        ref.read(logsProvider.notifier).state.where((log) => log != widget.logItem).toList();

    // Close the screen
    Navigator.of(context).pop();
  }

  String _getMacroLabel(String icon) {
    switch (icon) {
      case '🍗':
        return 'Protein';
      case '🍞':
        return 'Carbohydrates';
      case '🧀':
        return 'Fat';
      default:
        return 'Macro';
    }
  }

  IconData _getMacroIcon(String icon) {
    switch (icon) {
      case '🍗':
        return Icons.egg;
      case '🍞':
        return Icons.grain;
      case '🧀':
        return Icons.opacity;
      default:
        return Icons.food_bank;
    }
  }

  Color _getMacroColor(String icon) {
    switch (icon) {
      case '🍗':
        return Colors.red.shade700;  // Red for protein
      case '🍞':
        return Colors.amber.shade700;  // Amber for carbs
      case '🧀':
        return Colors.blue.shade700;  // Blue for fat
      default:
        return Colors.grey.shade700;
    }
  }
}