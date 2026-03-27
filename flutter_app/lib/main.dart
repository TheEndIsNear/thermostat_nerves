import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

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

// ---------------------------------------------------------------------------
// Home screen
// ---------------------------------------------------------------------------

class TemperaturePage extends StatefulWidget {
  const TemperaturePage({super.key});

  @override
  State<TemperaturePage> createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  double? _temperature;
  String _unit = 'C';
  int _utcOffsetSeconds = 0;
  String? _error;
  bool _connected = false;

  late ClientChannel _channel;
  late RPCClient _stub;
  StreamSubscription<TemperatureReading>? _subscription;

  late Timer? _timer;

  @override
  void initState() {
    super.initState();
    _connect();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
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
        if (!mounted) return;
        setState(() {
          _temperature = reading.value;
          _unit = reading.unit;
          _utcOffsetSeconds = reading.utcOffsetSeconds;
          _connected = true;
          _error = null;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _connected = false;
          _error = 'Connection lost. Retrying...';
        });
        _subscription?.cancel();
        Future.delayed(const Duration(seconds: 3), _startStream);
      },
      onDone: () {
        if (!mounted) return;
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
    _timer?.cancel();
    super.dispose();
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(stub: _stub, currentUnit: _unit),
      ),
    );
  }

  String _formatTemperature() {
    if (_temperature == null) return '--.-';
    return _temperature!.toStringAsFixed(1);
  }

  String _formatTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final local = DateTime.now().toUtc().add(
      Duration(seconds: _utcOffsetSeconds),
    );

    return "${twoDigits(local.hour)}:"
        "${twoDigits(local.minute)}:"
        "${twoDigits(local.second)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: GestureDetector(
        onLongPress: _openSettings,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Center(
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
                          color:
                              _connected
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _connected ? 'Live' : 'Connecting...',
                        style: TextStyle(
                          color:
                              _connected
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Current Time
                  Text(
                    _formatTime(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                    ),
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
                  const Text(
                    'Room Temperature',
                    style: TextStyle(color: Colors.white54, fontSize: 20),
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

            // Settings icon — top-right corner
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.white54),
                iconSize: 28,
                tooltip: 'Settings',
                onPressed: _openSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings screen
// ---------------------------------------------------------------------------

class SettingsPage extends StatefulWidget {
  final RPCClient stub;
  final String currentUnit;

  const SettingsPage({
    super.key,
    required this.stub,
    required this.currentUnit,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Unit
  late String _unit;
  bool _unitBusy = false;

  // Timezone
  List<String> _timezones = [];
  String? _selectedTimezone;
  bool _timezonesBusy = true;
  bool _timezoneSaving = false;
  String? _timezoneError;

  // Search
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredTimezones = [];
  bool _shiftEnabled = false;

  void _showKeyboard() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return VirtualKeyboard(
              height: 300,
              textColor: Colors.white,
              fontSize: 16,
              type: VirtualKeyboardType.Alphanumeric,
              defaultLayouts: const [VirtualKeyboardDefaultLayouts.English],
              postKeyPress: (key) {
                if (key.keyType == VirtualKeyboardKeyType.String) {
                  final char =
                      _shiftEnabled ? (key.capsText ?? '') : (key.text ?? '');
                  _searchController.text = _searchController.text + char;
                  _searchController.selection = TextSelection.collapsed(
                    offset: _searchController.text.length,
                  );
                } else if (key.keyType == VirtualKeyboardKeyType.Action) {
                  switch (key.action) {
                    case VirtualKeyboardKeyAction.Backspace:
                      final text = _searchController.text;
                      if (text.isNotEmpty) {
                        _searchController.text = text.substring(
                          0,
                          text.length - 1,
                        );
                        _searchController.selection = TextSelection.collapsed(
                          offset: _searchController.text.length,
                        );
                      }
                    case VirtualKeyboardKeyAction.Space:
                      _searchController.text = '${_searchController.text} ';
                      _searchController.selection = TextSelection.collapsed(
                        offset: _searchController.text.length,
                      );
                    case VirtualKeyboardKeyAction.Return:
                      Navigator.pop(ctx);
                    case VirtualKeyboardKeyAction.Shift:
                      setModalState(() => _shiftEnabled = !_shiftEnabled);
                    default:
                      break;
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _unit = widget.currentUnit;
    _loadTimezones();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTimezones =
          query.isEmpty
              ? _timezones
              : _timezones
                  .where((tz) => tz.toLowerCase().contains(query))
                  .toList();
    });
  }

  Future<void> _loadTimezones() async {
    try {
      final response = await widget.stub.getTimezones(Empty());
      if (!mounted) return;
      setState(() {
        _timezones = response.timezones;
        _filteredTimezones = response.timezones;
        _timezonesBusy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _timezoneError = 'Could not load timezones.';
        _timezonesBusy = false;
      });
    }
  }

  Future<void> _setUnit(String unit) async {
    setState(() => _unitBusy = true);
    try {
      await widget.stub.setUnit(UnitRequest(unit: unit));
      if (!mounted) return;
      setState(() {
        _unit = unit;
        _unitBusy = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _unitBusy = false);
    }
  }

  Future<void> _setTimezone(String timezone) async {
    setState(() {
      _timezoneSaving = true;
      _timezoneError = null;
    });
    try {
      await widget.stub.setTimezone(TimezoneRequest(timezone: timezone));
      if (!mounted) return;
      setState(() {
        _selectedTimezone = timezone;
        _timezoneSaving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _timezoneError = 'Failed to set timezone.';
        _timezoneSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // ----------------------------------------------------------------
          // Temperature unit
          // ----------------------------------------------------------------
          const Text(
            'TEMPERATURE UNIT',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _unitBusy
              ? const Center(
                child: SizedBox(
                  height: 36,
                  width: 36,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
              : SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'C', label: Text('°C  Celsius')),
                  ButtonSegment(value: 'F', label: Text('°F  Fahrenheit')),
                ],
                selected: {_unit},
                onSelectionChanged: (selection) => _setUnit(selection.first),
              ),

          const SizedBox(height: 36),

          // ----------------------------------------------------------------
          // Timezone
          // ----------------------------------------------------------------
          const Text(
            'TIMEZONE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          if (_selectedTimezone != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Current: $_selectedTimezone',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),

          if (_timezoneError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _timezoneError!,
                style: const TextStyle(color: Colors.orangeAccent),
              ),
            ),

          // Search field
          TextField(
            controller: _searchController,
            readOnly: true,
            onTap: _showKeyboard,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search timezones...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white38),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Timezone list
          if (_timezonesBusy)
            const Center(child: CircularProgressIndicator())
          else
            Container(
              height: 320,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  _timezoneSaving
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: _filteredTimezones.length,
                        itemBuilder: (context, index) {
                          final tz = _filteredTimezones[index];
                          final isSelected = tz == _selectedTimezone;
                          return ListTile(
                            dense: true,
                            title: Text(
                              tz,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.blueAccent
                                        : Colors.white,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                            trailing:
                                isSelected
                                    ? const Icon(
                                      Icons.check,
                                      color: Colors.blueAccent,
                                      size: 18,
                                    )
                                    : null,
                            onTap: () => _setTimezone(tz),
                          );
                        },
                      ),
            ),
        ],
      ),
    );
  }
}
