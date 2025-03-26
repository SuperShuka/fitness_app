import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/logs_notifier.dart';

class DescribeFoodScreen extends ConsumerStatefulWidget {
  @override
  _DescribeFoodScreenState createState() => _DescribeFoodScreenState();
}

class _DescribeFoodScreenState extends ConsumerState<DescribeFoodScreen> {
  final TextEditingController _foodController = TextEditingController();

  void _addFoodLog() {
    ref.read(logsProvider.notifier).addLogItemByDescription(
        context,
        _foodController.text
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Describe Food')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _foodController,
              decoration: InputDecoration(
                labelText: 'Enter Food Description',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addFoodLog,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}