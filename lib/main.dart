import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
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
  int i = 0;

  Future<int> pub(String topic, String message) async {
    print("-------------------------$i--------------------------");
    i++;

    final MqttClient client = MqttClient('111.230.31.218', '');

    client.logging(on: false);
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(message)
        .startClean();
    print('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      client.disconnect();
    }

    print('EXAMPLE::Publishing our topic');

    String pubTopic = topic;
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();

    builder.addString(message);
    client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload);

    print('EXAMPLE::Sleeping....');
    print('EXAMPLE::Disconnecting');

    await MqttUtilities.asyncSleep(10);

    return 0;
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');

  }

  /// The successful connect callback
  void onConnected() {
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }

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
          _buildInfoCard(context, accelerometer.toString()),
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

  Card _buildInfoCard(BuildContext context, String acc) {
    return Card(
      child: FlatButton(
        child: ListTile(
          title: Text("Nick name"),
          subtitle: Text('Topic name'),
        ),
        onPressed: () {
          setState(() {
//            pub("test", acc);
          });
        },
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
    String result = "";
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
        result = result + _accelerometerValues.toString();
        pub("test", "accelerometer:" + _accelerometerValues.toString());
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
        pub("test", "gyroscope:" + _gyroscopeValues.toString());
      });
    }));
    _streamSubscriptions.add(gravityEvents.listen((GravityEvent event) {
      setState(() {
        _gravityValues = <double>[event.x, event.y, event.z];
        pub("test", "gravity:" + _accelerometerValues.toString());
      });
    }));
    _streamSubscriptions.add(rotationEvents.listen((RotationEvent event) {
      setState(() {
        _rotationValues = <double>[event.x, event.y, event.z];
        pub("test", "rotation:" + _accelerometerValues.toString());
      });
    }));
  }
}
