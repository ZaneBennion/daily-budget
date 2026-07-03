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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget App')),
      body: Column(
        children: [
          BudgetDisplay(budget: budget,),
          Expanded(child: Keypad()),
        ],
      ),
    );
  }
}

class BudgetDisplay extends StatelessWidget {
  final int budget;

  const BudgetDisplay({super.key, required this.budget})

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: AppColors.blue,
    );
  }
}
