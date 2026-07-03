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

  void _handleButtonPress(int number) {
    setState(() {
      budget = (budget * 10) + number;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget App')),
      body: Column(
        children: [
          BudgetDisplay(budget: budget),
          Expanded(child: Keypad(onButtonPressed: _handleButtonPress)),
        ],
      ),
    );
  }
}

class BudgetDisplay extends StatelessWidget {
  final int budget;

  const BudgetDisplay({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: AppColors.blue,
      alignment: Alignment.centerRight,
      child: Text(
        '\$$budget',
        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class Keypad extends StatelessWidget {
  final void Function(int) onButtonPressed;

  const Keypad({super.key, required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    final numbers = [7, 8, 9, 4, 5, 6, 1, 2, 3, 0];

    return Container(
      color: AppColors.bgAccent,
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: numbers.map((number) {
          return FilledButton(
            onPressed: () => onButtonPressed(number),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.bg,
              foregroundColor: AppColors.text,
            ),
            child: Text('$number', style: const TextStyle(fontSize: 24)),
          );
        }).toList(),
      ),
    );
  }
}
