import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter/material.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({Key key, this.topic, this.nickname}) : super(key: key);

  final String topic;
  final String nickname;

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<DetailsPage> {
  String _accelerometerValues = "[0.0,0.0,0.0]";
  String _gyroscopeValues = "[0.0,0.0,0.0]";
  String _gravityValues = "[0.0,0.0,0.0]";
  String _rotationValues = "[0.0,0.0,0.0]";
  MqttClient subclient;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //mqtt broker 地址
    String mqttBroker ="";
    subclient = MqttClient(mqttBroker, '');
    sub(subclient, widget.topic);
  }

  void dispose() {
    super.dispose();
    subclient.unsubscribe(widget.topic);
    subclient.disconnect();
  }

  Future<int> sub(MqttClient client, String topic) async {
    client.logging(on: false);
    client.keepAlivePeriod = 2;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier("sub" + topic.toString())
        .keepAliveFor(2)
        .startClean();

    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on Exception catch (e) {
      client.disconnect();
    }

    if (client.connectionStatus.state == MqttConnectionState.connected) {
      String topic = widget.topic; // Not a wildcard topic
      client.subscribe(topic, MqttQos.atMostOnce);
      client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload;
        final String pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        String sensor = pt.split(":")[0];
        List<String> data = pt.split(":")[1].split(",");

        String x = double.parse(data[0].split("[")[1]).toStringAsFixed(4);
        String y = double.parse(data[1]).toStringAsFixed(4);
        String z = double.parse(data[2].split("]")[0]).toStringAsFixed(4);

        setState(() {
          switch (sensor) {
            case "accelerometer":
              _accelerometerValues = "x: " + x + " y: " + y + " z: " + z;
              break;
            case "gyroscope":
              _gyroscopeValues = "x: " + x + " y: " + y + " z: " + z;
              break;
            case "rotation":
              _rotationValues = "x: " + x + " y: " + y + " z: " + z;
              break;
            case "gravity":
              _gravityValues = "x: " + x + " y: " + y + " z: " + z;
              break;
          }
        });

        print('');
      });
    } else {
      client.disconnect();
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppbar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0,left: 15.0,right: 15.0),
          child: Column(
            children: <Widget>[
              buildInfoCard(context, "Topic Name", widget.topic),
              buildInfoCard(context, "Accelerometer", _accelerometerValues),
              buildInfoCard(context, "Gyroscope", _gyroscopeValues),
              buildInfoCard(context, "Gravity", _gravityValues),
              buildInfoCard(context, "Rotation", _rotationValues),
            ],
          ),
        ),
      ),
    );
  }

  AppBar buildAppbar(BuildContext context) {
    return AppBar(
      title: Text(
        widget.nickname,
        style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w500),
      ),
    );
  }

  Padding buildInfoCard(BuildContext context, String title, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 5.0,
        child: Column(
          children: <Widget>[
            Container(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
              color: Colors.blue,
              constraints: BoxConstraints.expand(
                height:
                    Theme.of(context).textTheme.display1.fontSize * 1.1 + 10,
              ),
            ),
            Container(
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
                ),
              ),
              constraints: BoxConstraints.expand(
                height:
                    Theme.of(context).textTheme.display1.fontSize * 1.1 + 10,
              ),
            )
          ],
        ),
      ),
    );
  }
}
