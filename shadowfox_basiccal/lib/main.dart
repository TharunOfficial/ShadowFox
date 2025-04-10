import 'package:flutter/material.dart';

void main() => runApp(CalculatorApp());

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Red & White Calculator',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          headlineMedium: TextStyle(color: Colors.red, fontSize: 36, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.red, fontSize: 24),
        ),
        buttonTheme: ButtonThemeData(buttonColor: Colors.red),
      ),
      home: CalculatorHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorHome extends StatefulWidget {
  @override
  _CalculatorHomeState createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String _expression = '';
  String _result = '';

  void _onPressed(String text) {
    setState(() {
      if (text == 'C') {
        _expression = '';
        _result = '';
      } else if (text == '=') {
        try {
          _result = _evaluate(_expression);
        } catch (e) {
          _result = 'Error';
        }
      } else {
        _expression += text;
      }
    });
  }

  String _evaluate(String expr) {
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');
    final exp = expr;
    double res = double.parse(_calculate(exp).toStringAsFixed(2));
    return res.toString();
  }

  double _calculate(String exp) {
    final parsed = exp.split(RegExp(r'([+\-*/])')).where((s) => s.isNotEmpty).toList();
    final ops = RegExp(r'[\+\-\*/]').allMatches(exp).map((e) => e.group(0)!).toList();

    double result = double.parse(parsed[0]);

    for (int i = 0; i < ops.length; i++) {
      double next = double.parse(parsed[i + 1]);
      switch (ops[i]) {
        case '+':
          result += next;
          break;
        case '-':
          result -= next;
          break;
        case '*':
          result *= next;
          break;
        case '/':
          result /= next;
          break;
      }
    }

    return result;
  }

  Widget _buildButton(String text, {double fontSize = 24}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: text == 'C' ? Colors.red.shade100 : Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: 20),
          ),
          child: Text(text, style: TextStyle(fontSize: fontSize, color: Colors.white)),
          onPressed: () => _onPressed(text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_expression, style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 10),
                  Text(_result, style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Row(children: [_buildButton('7'), _buildButton('8'), _buildButton('9'), _buildButton('÷')]),
              Row(children: [_buildButton('4'), _buildButton('5'), _buildButton('6'), _buildButton('×')]),
              Row(children: [_buildButton('1'), _buildButton('2'), _buildButton('3'), _buildButton('-')]),
              Row(children: [_buildButton('C'), _buildButton('0'), _buildButton('='), _buildButton('+')]),
            ],
          ),
        ],
      ),
    );
  }
}
