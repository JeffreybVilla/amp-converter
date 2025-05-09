import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AmpConverterApp());
}

class AmpConverterApp extends StatelessWidget {
  const AmpConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amp Converter',
      home: Scaffold(
        appBar: AppBar(title: const Text('Eastern Sierra Group: Amp Converter')),
        body: const AmpForm(),
      ),
    );
  }
}

class AmpForm extends StatefulWidget {
  const AmpForm({super.key});

  @override
  State<AmpForm> createState() => _AmpFormState();
}

class _AmpFormState extends State<AmpForm> {
  final TextEditingController _ampsController = TextEditingController();
  String _result = '';

      Future<String> _getTemperature() async {
        final url = Uri.parse('https://ampconverter.vercel.app/api/weather');

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final temp = (data['temp'] as num).toStringAsFixed(0);
          return '$temp°F';
        } else {
          return 'N/A';
        }
      } catch (e) {
        return 'N/A';
      }
}


  void _convert() async {
    final double amps208 = double.tryParse(_ampsController.text) ?? 0;
    final double power = 1.732 * 208 * amps208;
    final double amps480 = power / (1.732 * 480);
    final double kW = power / 1000;
    final String temp = await _getTemperature();

    final resultText =
        '208V: ${amps208.toStringAsFixed(0)} A\n'
        '480V: ${amps480.toStringAsFixed(0)} A\n'
        'kW: ${kW.toStringAsFixed(0)}\n'
        'Temp: $temp';

    Clipboard.setData(ClipboardData(text: resultText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Copied to clipboard!', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );

    setState(() {
      _result = resultText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Center(
              child: Image.asset(
                'assets/images/esg_logo_black.png',
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _ampsController,
            onSubmitted: (_) => _convert(),
            decoration: const InputDecoration(
              labelText: 'Amps at 208V',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _convert,
            child: const Text('Convert to 480V Amps + kW'),
          ),
          const SizedBox(height: 24),
          if (_result.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _result
                        .split('\n')
                        .map((line) => Text('• $line', style: const TextStyle(fontSize: 16)))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _result));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green[600],
                        duration: const Duration(seconds: 2),
                        content: Row(
                          children: const [
                            Icon(Icons.copy, color: Colors.white),
                            SizedBox(width: 10),
                            Text('Copied to clipboard!', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Result'),
                ),
              ],
            ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                const Text(
                  'Reference Conversion Chart:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Image.asset(
                      'assets/images/amp_chart.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
