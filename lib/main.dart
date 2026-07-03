import 'package:budget_app/colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Budget App', home: BudgetScreen());
  }
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  int budget = 0;
  String pendingTransaction = '';

  void _handleButtonPress(String value) {
    setState(() {
      if (value == 'C') {
        pendingTransaction = '';
      } else if (value == '=') {
        if (pendingTransaction.isNotEmpty) {
          int subtractionAmount = int.parse(pendingTransaction);
          budget -= subtractionAmount;
          pendingTransaction = '';
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        }
      } else {
        pendingTransaction += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget App')),
      body: Column(
        children: [
          BudgetDisplay(budget: budget, pendingTransaction: pendingTransaction),
          Expanded(child: Keypad(onButtonPressed: _handleButtonPress)),
        ],
      ),
    );
  }
}

class BudgetDisplay extends StatelessWidget {
  final int budget;
  final String pendingTransaction;

  const BudgetDisplay({
    super.key,
    required this.budget,
    required this.pendingTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: AppColors.blue,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              child: Text(
                '\$$budget',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (pendingTransaction.isNotEmpty)
            Expanded(
              flex: 1,
              child: Container(
                color: AppColors.pink,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 0,
                ),
                child: Text(
                  '-$pendingTransaction',
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Keypad extends StatelessWidget {
  final void Function(String) onButtonPressed;

  const Keypad({super.key, required this.onButtonPressed});

  Widget _buildButtonRow(List<String> buttons) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((text) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: FilledButton(
                onPressed: () => onButtonPressed(text),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.bgAccent,
                  foregroundColor: AppColors.text,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(text, style: const TextStyle(fontSize: 24)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildButtonRow(['7', '8', '9']),
          _buildButtonRow(['4', '5', '6']),
          _buildButtonRow(['1', '2', '3']),
          _buildButtonRow(['C', '0', '=']),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings page will go here')),
    );
  }
}
