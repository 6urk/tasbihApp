import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Istaghfirullah Counter',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const IstaghfirullahCounter(),
    );
  }
}

class IstaghfirullahCounter extends StatefulWidget {
  const IstaghfirullahCounter({Key? key}) : super(key: key);

  @override
  _IstaghfirullahCounterState createState() => _IstaghfirullahCounterState();
}

class _IstaghfirullahCounterState extends State<IstaghfirullahCounter> {
  int _counter = 0;
  bool _isListening = false;
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    _loadCounter();
    _initSpeechRecognition();
  }

  void _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
    });
  }

  void _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', _counter);
  }

  void _initSpeechRecognition() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech recognition status: $status'),
      onError: (errorNotification) => print('Speech recognition error: $errorNotification'),
    );
    if (available) {
      setState(() => _isListening = false);
    } else {
      print("Speech recognition not available");
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    _saveCounter();
  }

  void _toggleListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    } else {
      _startListening();
    }
  }

  void _startListening() {
    _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.toLowerCase().contains('istaghfirullah') ||
            result.recognizedWords.contains('استغفر الله')) {
          _incrementCounter();
        }
      },
    );
    setState(() => _isListening = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Istaghfirullah Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Istaghfirullah Count:',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              '$_counter',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _incrementCounter,
              child: const Text('Manual Count'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleListening,
              child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isListening ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}