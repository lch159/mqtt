import 'dart:async';
import 'package:flutter/material.dart';
import 'sensors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensors Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<double> _accelerometerValues;
  List<double> _gyroscopeValues;
  List<double> _gravityValues;
  List<double> _rotationValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  @override
  Widget build(BuildContext context) {
    final List<String> accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();

    final List<String> gravity =
        _gravityValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> rotation =
        _rotationValues?.map((double v) => v.toStringAsFixed(1))?.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Example'),
      ),
      body: Column(
//        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Card(
            child: FlatButton(
              child: ListTile(
                title: Text("Nick name"),
                subtitle: Text('Topic name'),
              ),
              onPressed: () {
                setState(() {
                  showDialog<Null>(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        title: Text("Nick name"),
                        titlePadding: EdgeInsets.all(24.0),
                        children: <Widget>[
                          Text('Accelerometer: $accelerometer'),
                          Text('Gyroscope: $gyroscope'),
                          Text('Gravity: $gravity'),
                          Text('Rotaion: $rotation'),
                        ],
                      );
                    },
                  );
                });
              },
            ),
          ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Accelerometer: $accelerometer'),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Gyroscope: $gyroscope'),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Gravity: $gravity'),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Rotaion: $rotation'),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
        ],
      ),
    );
  }

  Card _buildInfoCard(BuildContext context) {
    return Card(
      child: FlatButton(
        child: ListTile(
          title: Text("Nick name"),
          subtitle: Text('Topic name'),
        ),
        onPressed: () {},
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(gravityEvents.listen((GravityEvent event) {
      setState(() {
        _gravityValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(rotationEvents.listen((RotationEvent event) {
      setState(() {
        _rotationValues = <double>[event.x, event.y, event.z];
      });
    }));
  }
}
