import 'package:flutter/material.dart';

void main() {
  runApp(FuelCostApp());
}

class FuelCostApp extends StatelessWidget {
  const FuelCostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '油耗成本計算',
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
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController consumptionController = TextEditingController();
  final TextEditingController fuelPriceController = TextEditingController();

  String result = '';

  void calculateCost() {
    final double distance = double.tryParse(distanceController.text) ?? 0;
    final double consumption = double.tryParse(consumptionController.text) ?? 0;
    final double fuelPrice = double.tryParse(fuelPriceController.text) ?? 0;

    if (distance <= 0 || consumption <= 0 || fuelPrice <= 0) {
      setState(() {
        result = '請輸入有效數據';
      });
      return;
    }

    final cost = (distance / consumption) * fuelPrice;

    setState(() {
      result = '總成本：NT\$${cost.toStringAsFixed(2)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('油耗成本計算'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: distanceController,
              decoration: InputDecoration(
                labelText: '行駛距離 (公里)',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: consumptionController,
              decoration: InputDecoration(
                labelText: '油耗 (公里/公升)',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: fuelPriceController,
              decoration: InputDecoration(
                labelText: '油價 (每公升價格)',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateCost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('計算成本'),
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
