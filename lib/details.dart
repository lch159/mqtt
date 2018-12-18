import 'dart:async';

import 'package:flutter/material.dart';
import 'sensors.dart';

class Details extends StatefulWidget {
  const Details({
    Key key,
    this.accelerometer,
    this.gyroscope,
    this.gravity,
    this.rotation,
    this.topic,
  }) : super(key: key);
  final String accelerometer;
  final String gyroscope;
  final String gravity;
  final String rotation;
  final String topic;

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  List<double> _accelerometerValues;
  List<double> _gyroscopeValues;
  List<double> _gravityValues;
  List<double> _rotationValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    // TODO: implement initState
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
      appBar: buildAppbar(context),
      body: Column(
        children: <Widget>[
          buildInfoCard(context, "Topic Name", widget.topic),
          buildInfoCard(context, "Accelerometer", widget.accelerometer),
          buildInfoCard(context, "Gyroscope", widget.gyroscope),
          buildInfoCard(context, "Gravity", widget.gravity),
          buildInfoCard(context, "Rotation", widget.rotation),
        ],
      ),
    );
  }

  AppBar buildAppbar(BuildContext context) {
    return AppBar(
      title: Text("Nick Name"),
    );
  }

  Card buildInfoCard(BuildContext context, String title, String text) {
    return Card(
      child: Column(
        children: <Widget>[
          Container(
            child: Text(title),
          ),
          Divider(),
          Center(
            child: Text(text),
          )
        ],
      ),
    );
  }
}
