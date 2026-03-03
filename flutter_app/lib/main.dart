import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';

import 'generated/temperature.pbgrpc.dart';

void main() {
  runApp(const ThermostatApp());
}

class ThermostatApp extends StatelessWidget {
  const ThermostatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thermostat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const TemperaturePage(),
    );
  }
}

class TemperaturePage extends StatefulWidget {
  const TemperaturePage({super.key});

  @override
  State<TemperaturePage> createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  double? _temperature;
  String _unit = 'C';
  String? _error;
  bool _connected = false;

  late ClientChannel _channel;
  late RPCClient _stub;
  StreamSubscription<TemperatureReading>? _subscription;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() {
    _channel = ClientChannel(
      'localhost',
      port: 50051,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    _stub = RPCClient(_channel);
    _startStream();
  }

  void _startStream() {
    setState(() {
      _error = null;
    });

    final stream = _stub.streamTemperature(Empty());
    _subscription = stream.listen(
      (reading) {
        setState(() {
          _temperature = reading.value;
          _unit = reading.unit;
          _connected = true;
          _error = null;
        });
      },
      onError: (error) {
        setState(() {
          _connected = false;
          _error = 'Connection lost. Retrying...';
        });
        _subscription?.cancel();
        Future.delayed(const Duration(seconds: 3), _startStream);
      },
      onDone: () {
        setState(() {
          _connected = false;
        });
        Future.delayed(const Duration(seconds: 3), _startStream);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _channel.shutdown();
    super.dispose();
  }

  String _formatTemperature() {
    if (_temperature == null) return '--.-';
    return _temperature!.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _connected ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _connected ? 'Live' : 'Connecting...',
                  style: TextStyle(
                    color: _connected ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Temperature reading
            Text(
              '${_formatTemperature()} °$_unit',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 72,
                fontWeight: FontWeight.w300,
              ),
            ),

            const SizedBox(height: 16),

            // Label
            Text(
              'Room Temperature',
              style: const TextStyle(color: Colors.white54, fontSize: 20),
            ),

            // Error message
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
