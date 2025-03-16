import 'dart:convert';               // 用於 jsonEncode / jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const FuelCostApp());
}

class FuelCostApp extends StatelessWidget {
  const FuelCostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '加油成本紀錄',
      home: const FuelCostHomePage(),
    );
  }
}

class FuelCostHomePage extends StatefulWidget {
  const FuelCostHomePage({super.key});

  @override
  State<FuelCostHomePage> createState() => _FuelCostHomePageState();
}

class _FuelCostHomePageState extends State<FuelCostHomePage> {
  final TextEditingController costController = TextEditingController();
  final TextEditingController distanceController = TextEditingController();

  final List<double> costList = [];
  final List<double> distanceList = [];
  final List<double?> costPerKmList = [];
  final List<DateTime> dateTimeList = [];

  /// 最新成功被計算出每公里成本的索引
  int latestCalculatedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData(); // 進入畫面時讀取已儲存的加油紀錄
  }

  /// 從 SharedPreferences 載入資料
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // costList
    final costString = prefs.getString('costList');
    if (costString != null) {
      final List<dynamic> decoded = jsonDecode(costString);
      costList.clear();
      costList.addAll(decoded.map((e) => e as double));
    }

    // distanceList
    final distanceString = prefs.getString('distanceList');
    if (distanceString != null) {
      final List<dynamic> decoded = jsonDecode(distanceString);
      distanceList.clear();
      distanceList.addAll(decoded.map((e) => e as double));
    }

    // costPerKmList
    final costPerKmString = prefs.getString('costPerKmList');
    if (costPerKmString != null) {
      final List<dynamic> decoded = jsonDecode(costPerKmString);
      costPerKmList.clear();
      costPerKmList.addAll(decoded.map((e) {
        if (e == null) return null;
        return e as double;
      }));
    }

    // dateTimeList
    final dateTimeString = prefs.getString('dateTimeList');
    if (dateTimeString != null) {
      final List<dynamic> decoded = jsonDecode(dateTimeString);
      dateTimeList.clear();
      dateTimeList.addAll(
        decoded.map((ms) => DateTime.fromMillisecondsSinceEpoch(ms as int)),
      );
    }

    // latestCalculatedIndex
    latestCalculatedIndex = prefs.getInt('latestCalculatedIndex') ?? -1;

    setState(() {});
  }

  /// 儲存資料到 SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // costList
    await prefs.setString('costList', jsonEncode(costList));
    // distanceList
    await prefs.setString('distanceList', jsonEncode(distanceList));
    // costPerKmList
    await prefs.setString('costPerKmList', jsonEncode(costPerKmList));
    // dateTimeList (先轉 milliseconds)
    final dtList = dateTimeList.map((d) => d.millisecondsSinceEpoch).toList();
    await prefs.setString('dateTimeList', jsonEncode(dtList));
    // latestCalculatedIndex
    await prefs.setInt('latestCalculatedIndex', latestCalculatedIndex);
  }

  void _addFuelRecord() async {
    final double cost = double.tryParse(costController.text) ?? 0;
    final double distance = double.tryParse(distanceController.text) ?? 0;

    if (cost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入「本次加油金額」，且必須 > 0')),
      );
      return;
    }

    // 如果已有紀錄，更新上一筆的每公里成本
    if (costList.isNotEmpty) {
      if (distance <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('請輸入「上次加油到這次的里程」，且必須 > 0')),
        );
        return;
      }
      costPerKmList[0] = costList[0] / distance;
      distanceList[0] = distance;
    }

    // 新紀錄插入最前面
    costList.insert(0, cost);
    costPerKmList.insert(0, null);
    distanceList.insert(0, 0);
    dateTimeList.insert(0, DateTime.now());

    // 舊的紀錄被擠到 index=1
    if (costList.length > 1) {
      latestCalculatedIndex = 1;
    } else {
      // 第一次加油
      latestCalculatedIndex = -1;
    }

    costController.clear();
    distanceController.clear();

    setState(() {});
    await _saveData();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFirstEntry = costList.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('加油成本紀錄'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: costController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '本次加油金額 (元)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: distanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: !isFirstEntry,
              decoration: InputDecoration(
                labelText: isFirstEntry
                    ? '首次加油無需輸入里程'
                    : '上次加油到這次的里程 (km)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addFuelRecord,
              child: const Text('新增/計算'),
            ),
            const SizedBox(height: 20),

            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: costList.length,
              itemBuilder: (context, index) {
                final currentCost = costList[index];
                final currentDistance = distanceList[index];
                final currentCostPerKm = costPerKmList[index];
                final currentTime = dateTimeList[index];

                final bool isPendingDistance = (currentDistance == 0);
                final bool isLatestCalculated = (index == latestCalculatedIndex);

                // 1) 顯示加油金額文字
                // index=0 → "本次加油金額"
                // index>0 → "上次加油金額"
                final String costTitleText = (index == 0)
                    ? '本次加油金額：\$${currentCost.toStringAsFixed(0)}'
                    : '上次加油金額：\$${currentCost.toStringAsFixed(0)}';

                // 2) 每公里成本
                final String costPerKmText = (currentCostPerKm == null)
                    ? '每公里成本：尚未計算'
                    : '上次每公里成本：\$${currentCostPerKm.toStringAsFixed(2)}';

                // 3) 里程
                final String kmText = (currentDistance == 0)
                    ? '待下次加油新增里程'
                    : '里程:${currentDistance.toStringAsFixed(0)} km';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  color: isPendingDistance ? Colors.grey.shade300 : null,
                  child: ListTile(
                    title: Text(
                      costTitleText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPendingDistance ? Colors.black54 : Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kmText,
                          style: TextStyle(
                            color: isPendingDistance ? Colors.black54 : Colors.black,
                          ),
                        ),
                        if (currentCostPerKm == null)
                          Text(
                            costPerKmText,
                            style: const TextStyle(color: Colors.black54),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: isLatestCalculated
                                ? BoxDecoration(
                                    color: Colors.red.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  )
                                : null,
                            child: Text(
                              costPerKmText,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isLatestCalculated ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: Text(
                      '${currentTime.month}/${currentTime.day} '
                      '${currentTime.hour}:${currentTime.minute}',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
