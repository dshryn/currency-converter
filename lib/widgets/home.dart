import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyConverterApp extends StatefulWidget {
  const CurrencyConverterApp({super.key});

  @override
  State<CurrencyConverterApp> createState() => _CurrencyConverterAppState();
}

class _CurrencyConverterAppState extends State<CurrencyConverterApp> {
  String fromCurr = 'USD';
  String toCurr = 'EUR';
  double rate = 0.0;
  double total = 0.0;
  TextEditingController amountController = TextEditingController();
  List<String> currencies = ['USD', 'EUR', 'GBP', 'INR'];

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _getRate();
    setState(() {
      total = 0.0;
    });
  }

  Future<void> _getRate() async {
    var response = await http
        .get(Uri.parse('https://api.exchangerate-api.com/v4/latest/$fromCurr'));

    var data = json.decode(response.body);
    setState(() {
      rate = data['rates'][toCurr];
    });
    _updateTotal();
  }

  void _updateTotal() {
    if (amountController.text.isNotEmpty) {
      double amount = double.parse(amountController.text);
      setState(() {
        total = amount * rate;
      });
    } else {
      setState(() {
        total = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 1, 41),
        appBar: AppBar(
          title: const Text(
            'Currency Converter',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 0, 2, 15),
        ),
        body: Padding(
          padding: const EdgeInsets.all(17),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(38),
                  child: Opacity(
                    opacity: 0.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(200.0),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Amount",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      labelStyle: const TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    onChanged: (value) {
                      _updateTotal();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        child: DropdownButton<String>(
                          value: fromCurr,
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white),
                          dropdownColor: const Color.fromARGB(255, 0, 2, 15),
                          items: currencies.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              fromCurr = newValue!;
                              _initializeState();
                            });
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _swapCurrencies();
                        },
                        icon: const Icon(
                          Icons.swap_horiz,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: DropdownButton<String>(
                          value: toCurr,
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white),
                          dropdownColor: const Color.fromARGB(255, 0, 2, 15),
                          items: currencies.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              toCurr = newValue!;
                              _initializeState();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Rate: $rate",
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 30),
                Text(
                  total.toStringAsFixed(3),
                  style: const TextStyle(
                    fontSize: 40,
                    color: Color.fromARGB(255, 204, 195, 255),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _swapCurrencies() {
    setState(() {
      String temp = fromCurr;
      fromCurr = toCurr;
      toCurr = temp;
    });
    _getRate();
  }
}
