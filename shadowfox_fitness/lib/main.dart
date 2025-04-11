import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(FitnessApp());

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.red),
      ),
      home: FitnessHomePage(),
    );
  }
}

class FitnessHomePage extends StatefulWidget {
  @override
  _FitnessHomePageState createState() => _FitnessHomePageState();
}

class _FitnessHomePageState extends State<FitnessHomePage> {
  late Stream<StepCount> _stepCountStream;
  int _steps = 0;
  int _goal = 5000;

  TextEditingController goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadGoal();
    initPlatformState();
  }

  void initPlatformState() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError((error) {
      print('Pedometer error: $error');
    });
  }

  void onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps;
    });
  }

  Future<void> loadGoal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _goal = prefs.getInt('goal') ?? 5000;
    });
  }

  Future<void> saveGoal(int newGoal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('goal', newGoal);
    setState(() {
      _goal = newGoal;
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_steps / _goal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness Tracker'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Steps Today', style: TextStyle(fontSize: 22)),
            SizedBox(height: 10),
            Text('$_steps', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.red.shade100,
              color: Colors.red,
              minHeight: 12,
            ),
            SizedBox(height: 10),
            Text('Goal: $_goal steps', style: TextStyle(fontSize: 16)),
            Divider(height: 40),
            Text('Set Custom Goal', style: TextStyle(fontSize: 18)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: goalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter steps...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    int? newGoal = int.tryParse(goalController.text);
                    if (newGoal != null && newGoal > 0) {
                      saveGoal(newGoal);
                      goalController.clear();
                    }
                  },
                  child: Text('Set'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
