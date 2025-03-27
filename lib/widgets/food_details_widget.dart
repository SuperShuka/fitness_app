import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  late List<TextEditingController> _macroControllers;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.logItem.name);
    _caloriesController = TextEditingController(text: widget.logItem.calories.toString());

    // Initialize macro controllers
    _macroControllers = widget.logItem.macros?.map((macro) =>
        TextEditingController(text: macro.value.toString())
    ).toList() ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    for (var controller in _macroControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteLogItem,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Calories Input
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Calories',
                prefixIcon: Icon(Icons.local_fire_department),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Macros Inputs
            if (widget.logItem.macros != null)
              ...widget.logItem.macros!.asMap().entries.map((entry) {
                final index = entry.key;
                final macro = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _macroControllers[index],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: _getMacroLabel(macro.icon),
                      prefixIcon: Icon(_getMacroIcon(macro.icon)),
                      suffixText: 'g',
                      border: OutlineInputBorder(),
                    ),
                  ),
                );
              }).toList(),

            // Save Button
            ElevatedButton(
              onPressed: _saveLogItem,
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMacroLabel(String icon) {
    switch (icon) {
      case '🍗':
        return 'Protein';
      case '🍞':
        return 'Carbs';
      case '🧀':
        return 'Fat';
      default:
        return 'Macro';
    }
  }

  IconData _getMacroIcon(String icon) {
    switch (icon) {
      case '🍗':
        return Icons.set_meal;
      case '🍞':
        return Icons.bakery_dining;
      case '🧀':
        return Icons.fastfood;
      default:
        return Icons.fastfood;
    }
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
      image: widget.logItem.image,
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
}