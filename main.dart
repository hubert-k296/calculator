import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Calculator');
    setWindowMinSize(const Size(400, 600));
    setWindowMaxSize(const Size(600, 800));
    setWindowFrame(const Rect.fromLTWH(100, 100, 420, 680));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Calculator(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String output = "0";

  void onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        output = "0";
      } else if (value == "=") {
        try {
          output = evaluateExpression(output);
        } catch (e) {
          output = "Error";
        }
      } else {
        if (output == "0" && RegExp(r'\d').hasMatch(value)) {
          output = value;
        } else if (RegExp(r'[\+\-\*\/]').hasMatch(value)) {
          if (RegExp(r'[\+\-\*\/]').hasMatch(output[output.length - 1])) {
            output = output.substring(0, output.length - 1) + value;
          } else {
            output += value;
          }
        } else {
          output += value;
        }
      }
    });
  }

  String evaluateExpression(String expression) {
    try {
      List<String> operators = [];
      List<double> numbers = [];

      RegExp regExp = RegExp(r'(\d+\.?\d*)|[\+\-\*\/]');
      Iterable<RegExpMatch> matches = regExp.allMatches(expression);

      for (var match in matches) {
        String token = match.group(0)!;
        if (RegExp(r'[\+\-\*\/]').hasMatch(token)) {
          operators.add(token);
        } else {
          numbers.add(double.parse(token));
        }
      }

      double result = numbers[0];
      for (int i = 0; i < operators.length; i++) {
        if (operators[i] == "+") {
          result += numbers[i + 1];
        } else if (operators[i] == "-") {
          result -= numbers[i + 1];
        } else if (operators[i] == "*") {
          result *= numbers[i + 1];
        } else if (operators[i] == "/") {
          result /= numbers[i + 1];
        }
      }

      return result.toString();
    } catch (e) {
      return "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> buttons = [
      "7", "8", "9", "/",
      "4", "5", "6", "*",
      "1", "2", "3", "-",
      "C", "0", "=", "+",
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Calculator')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            children: [
              // Display
              Container(
                height: 150,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(16),
                child: Text(
                  output,
                  style: const TextStyle(fontSize: 48, color: Colors.white),
                ),
              ),
              // Buttons
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 4,
                    crossAxisSpacing: 9,
                    mainAxisSpacing: 9,
                    childAspectRatio: 1.2,
                    children: buttons.map((btnText) {
                      bool isOperator = RegExp(r'[\+\-\*\/=]').hasMatch(btnText);

                      return ElevatedButton(
                        onPressed: () => onButtonPressed(btnText),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          isOperator ? Colors.orange : Colors.grey[850],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: Text(
                          btnText,
                          style: const TextStyle(fontSize: 28),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
