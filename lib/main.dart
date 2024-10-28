import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

class ProximitySensorGraph extends StatefulWidget {
  @override
  _ProximitySensorGraphState createState() => _ProximitySensorGraphState();
}

class _ProximitySensorGraphState extends State<ProximitySensorGraph> {
  bool _isNear = false;
  int _distance = 30;
  final List<FlSpot> _dataPoints = [const FlSpot(0, 0)];
  Timer? _timer;
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _startProximitySensor();
    _startDataUpdateTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startProximitySensor() {
    ProximitySensor.events.listen((int event) {
      setState(() {
        _isNear = event > 0;
        // Simulate distance values based on proximity status
        _distance = _isNear ? Random().nextInt(10) + 1 : 0;
        _addDataPoint(_distance.toDouble());
      });
    });
  }

  void _startDataUpdateTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() {
        _time += 0.5;
        if (_dataPoints.length > 20) {
          _dataPoints.removeAt(0);
        }
      });
    });
  }

  void _addDataPoint(double value) {
    setState(() {
      _dataPoints.add(FlSpot(_time, value));
    });
  }

  LineChartData _buildChartData() {
    return LineChartData(
      /* minX: _dataPoints.isEmpty ? 0 : _dataPoints.first.x,
      maxX: _time,
      minY: 0,
      maxY: 10,*/
      lineBarsData: [
        LineChartBarData(
          spots: _dataPoints,
          isCurved: true,
          color: Colors.blue.withOpacity(0.6),
          belowBarData:
              BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
          barWidth: 3,
          dotData: const FlDotData(show: true),
        ),
      ],
      /* titlesData: const FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles:
              SideTitles(showTitles: true, interval: 2, reservedSize: 40),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, interval: 2),
        ),
      ),*/
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Detect')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _isNear ? "Device Detected" : "No Device Found",
            style: TextStyle(
                fontSize: 15, color: !_isNear ? Colors.red : Colors.green),
          ),
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Card(
              shape: const CircleBorder(),
              elevation: 8,
              color: Colors.white60,
              child: Center(
                child: Text(
                  "$_distance",
                  style: TextStyle(
                      fontSize: 15,
                      color: !_isNear ? Colors.red : Colors.green),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LineChart(_buildChartData()),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ProximitySensorGraph()));
}
