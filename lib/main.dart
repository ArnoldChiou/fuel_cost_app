import 'package:flutter/material.dart';

void main() {
  runApp(FuelCostApp());
}

class FuelCostApp extends StatelessWidget {
  const FuelCostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '每公里成本計算',
      home: FuelCostCalculator(),
    );
  }
}

class FuelCostCalculator extends StatefulWidget {
  const FuelCostCalculator({super.key});

  @override
  _FuelCostCalculatorState createState() => _FuelCostCalculatorState();
}

class _FuelCostCalculatorState extends State<FuelCostCalculator> {
  final TextEditingController litersController = TextEditingController();
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController totalCostController = TextEditingController();

  String result = '';

  void calculateCost() {
    final double liters = double.tryParse(litersController.text) ?? 0;
    final double distance = double.tryParse(distanceController.text) ?? 0;
    final double totalCost = double.tryParse(totalCostController.text) ?? 0;

    if (liters <= 0 || distance <= 0 || totalCost <= 0) {
      setState(() {
        result = '請輸入有效數據';
      });
      return;
    }

    final costPerKm = totalCost / distance;

    setState(() {
      result = '每公里成本：NT\$${costPerKm.toStringAsFixed(2)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('每公里成本計算'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView( // 加上這一層解決溢出問題
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: litersController,
              decoration: InputDecoration(
                labelText: '加油公升數',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: distanceController,
              decoration: InputDecoration(
                labelText: '行駛距離 (公里)',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: totalCostController,
              decoration: InputDecoration(
                labelText: '加油總金額',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateCost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('計算每公里成本'),
            ),
            SizedBox(height: 20),
            Text(
              result,
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
