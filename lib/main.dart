import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SSEScreen(),
    );
  }
}

class SSEScreen extends StatefulWidget {
  @override
  _SSEScreenState createState() => _SSEScreenState();
}

class _SSEScreenState extends State<SSEScreen> {
  String message = '';
  double _progress = 0.0;
  bool hide = false;

  Future<void> startSSE() async {
    setState(() {
      hide = true;
    });
    final request =
        http.Request("POST", Uri.parse("http://10.0.2.2:3000/start"));
    final response = await http.Client().send(request);

    response.stream.transform(const Utf8Decoder()).listen((event) {
      final lines = event.split("\n");
      for (var line in lines) {
        if (line.startsWith("data: ")) {
          setState(() {
            message = line.substring(6);
            _progress = _progress + 0.2;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Abrir conta com SSE")),
      body: Column(
        children: [
          Spacer(),
          ListTile(title: Text(message)),
          Visibility(
            visible: hide,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LinearProgressIndicator(
                value: _progress,
                color: Colors.amberAccent,
              ),
            ),
          ),
          Visibility(
              visible: !hide,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.amberAccent),
                  fixedSize: WidgetStateProperty.all(Size(350, 50)),
                ),
                onPressed: startSSE,
                child: Text("Abrir conta"),
              )),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
