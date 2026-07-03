import 'package:budget_app/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAndCalcBudget();
  }

  Future<void> _loadAndCalcBudget() async {
    final prefs = await SharedPreferences.getInstance();

    int savedBudget = prefs.getInt('budget') ?? 0;
    int dailyAddAmount = prefs.getInt('dailyAddAmount') ?? 0;
    String? lastDateString = prefs.getString('lastAddedDate');

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    if (lastDateString != null) {
      DateTime lastDate = DateTime.parse(lastDateString);

      int daysPassed = today.difference(lastDate).inDays;
      if (daysPassed > 0) {
        savedBudget += (dailyAddAmount * daysPassed);

        await prefs.setInt('budget', savedBudget);
        await prefs.setString('lastAddedDate', today.toIso8601String());
      }
    } else {
      await prefs.setString('lastAddedDate', today.toIso8601String());
    }

    setState(() {
      budget = savedBudget;
    });
  }

  void _handleButtonPress(String value) async {
    if (value == 'C') {
      setState(() {
        pendingTransaction = '';
      });
    } else if (value == '=') {
      if (pendingTransaction.isNotEmpty) {
        int subtractionAmount = int.parse(pendingTransaction);
        setState(() {
          budget -= subtractionAmount;
          pendingTransaction = '';
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('budget', budget);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
      }
    } else {
      setState(() {
        pendingTransaction += value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isShortScreen = MediaQuery.of(context).size.height < 600;

    return Scaffold(
      appBar: isShortScreen ? null : AppBar(title: const Text('Budget App')),
      body: Column(
        children: [
          BudgetDisplay(budget: budget, pendingTransaction: pendingTransaction),
          Expanded(
            child: Keypad(
              onButtonPressed: _handleButtonPress,
              isPendingEmpty: pendingTransaction.isEmpty,
            ),
          ),
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
    final bool isEmpty = pendingTransaction.isEmpty;

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

          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            height: isEmpty ? 0 : 50,
            color: AppColors.pink,
            alignment: Alignment.centerRight,
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            child: Text(
              '-$pendingTransaction',
              style: const TextStyle(fontSize: 36),
            ),
          ),
        ],
      ),
    );
  }
}

class Keypad extends StatelessWidget {
  final void Function(String) onButtonPressed;
  final bool isPendingEmpty;

  const Keypad({
    super.key,
    required this.onButtonPressed,
    required this.isPendingEmpty,
  });

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
                child: text == '=' && isPendingEmpty
                    ? const Icon(Icons.settings, size: 28)
                    : Text(
                        text,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingAmount();
  }

  Future<void> _loadExistingAmount() async {
    final prefs = await SharedPreferences.getInstance();
    int currentAmount = prefs.getInt('dailyAddAmount') ?? 0;

    setState(() {
      _amountController.text = currentAmount.toString();
    });
  }

  Future<void> _saveAmount() async {
    final prefs = await SharedPreferences.getInstance();

    int newAmount = int.tryParse(_amountController.text) ?? 0;

    await prefs.setInt('dailyAddAmount', newAmount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Daily Budget Addition',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                labelText: 'Amount',
              ),
            ),

            FilledButton(
              onPressed: () => _saveAmount(),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
