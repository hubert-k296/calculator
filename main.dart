import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Calculator');
    setWindowMinSize(const Size(300, 500));
    setWindowMaxSize(Size.infinite); // Allow resizing freely
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          double buttonFontSize = constraints.maxWidth < 500 ? 18 : 28;  // Adjust button font size
          double outputFontSize = constraints.maxWidth < 500 ? 28 : 48;  // Adjust output font size
          double buttonPadding = constraints.maxWidth < 500 ? 6 : 12;  // Reduced padding

          return Column(
            children: [
              // Display area
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerRight,
                height: constraints.maxHeight * 0.18, // Display takes 18% of screen height
                child: Text(
                  output,
                  style: TextStyle(
                    fontSize: outputFontSize,
                    color: Colors.white,
                  ),
                ),
              ),

              // Buttons
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      childAspectRatio: constraints.maxWidth / (constraints.maxHeight * 0.8),  // Ensure buttons fit
                    ),
                    itemCount: buttons.length,
                    itemBuilder: (context, index) {
                      String btnText = buttons[index];
                      bool isOperator = RegExp(r'[\+\-\*\/=]').hasMatch(btnText);

                      return ElevatedButton(
                        onPressed: () => onButtonPressed(btnText),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOperator
                              ? Colors.orange
                              : Colors.grey[850],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(buttonPadding),
                        ),
                        child: Text(
                          btnText,
                          style: TextStyle(fontSize: buttonFontSize),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
