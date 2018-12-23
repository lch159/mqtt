import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/details.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'sensors.dart';
import 'package:device_info/device_info.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

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

  List<TopicCard> topics;

  TextEditingController inputTopicController = new TextEditingController();
  TextEditingController inputNicknameController = new TextEditingController();

  String _deviceName;

  @override
  void initState() {
    super.initState();
    String result = "";
    topics = new List();
    getID().then((id) {
      topics.add(TopicCard(
        topic: id,
        isDevice: true,
        nickname:
            "Click here to view the details of your device ($_deviceName)",
      ));
      _streamSubscriptions
          .add(accelerometerEvents.listen((AccelerometerEvent event) {
        setState(() {
          _accelerometerValues = <double>[event.x, event.y, event.z];
          result = result + _accelerometerValues.toString();
          pub(id, "accelerometer:" + _accelerometerValues.toString());
        });
      }));
      _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
        setState(() {
          _gyroscopeValues = <double>[event.x, event.y, event.z];
          pub(id, "gyroscope:" + _gyroscopeValues.toString());
        });
      }));
      _streamSubscriptions.add(gravityEvents.listen((GravityEvent event) {
        setState(() {
          _gravityValues = <double>[event.x, event.y, event.z];
          pub(id, "gravity:" + _gravityValues.toString());
        });
      }));
      _streamSubscriptions.add(rotationEvents.listen((RotationEvent event) {
        setState(() {
          _rotationValues = <double>[event.x, event.y, event.z];
          pub(id, "rotation:" + _rotationValues.toString());
        });
      }));
    });
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  Future<String> getID() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    _deviceName = androidDeviceInfo.model;
    return androidDeviceInfo.androidId;
  }

  Future<int> pub(String topic, String message) async {
    final MqttClient client = MqttClient('111.230.31.218', '');

    client.logging(on: false);
    client.keepAlivePeriod = 2;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(message)
        .keepAliveFor(2)
        .startClean();

    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on Exception catch (e) {
      client.disconnect();
    }

    if (client.connectionStatus.state == MqttConnectionState.connected) {
      String pubTopic = topic;
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload);
    } else {
      client.disconnect();
    }

    await MqttUtilities.asyncSleep(10);

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      floatingActionButton: _buildFloatingActionButton(context),
      body: new ListView.builder(
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final item = topics[index];
          return new Dismissible(
            key: new Key(topics[index].topic + topics[index].nickname),
            onDismissed: (direction) {
              print(direction);
              topics.removeAt(index);

              Scaffold.of(context).showSnackBar(
                  new SnackBar(content: new Text("$item dismissed")));
            },
            background: new Container(
              color: Colors.red,
            ),
            child: topics[index],
            direction: DismissDirection.endToStart,
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        "SensorDemo",
        style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w500),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        setState(() {
          showDialog<Null>(
            builder: (BuildContext context) {
              return SimpleDialog(
                title: Text('Add a Subscription'),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: inputTopicController,
                      decoration: InputDecoration(
                        hintText: "Please input the topic ",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: inputNicknameController,
                      decoration: InputDecoration(
                        hintText: "Please input the nick name",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                      child: Text('Confirm'),
                      onPressed: () {
                        setState(() {
                          if (inputTopicController.text != "" &&
                              inputNicknameController.text != "") {
                            topics.add(TopicCard(
                              topic: inputTopicController.text,
                              nickname: inputNicknameController.text,
                              isDevice: false,
                            ));
                            inputNicknameController.clear();
                            inputTopicController.clear();
                          }
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                  ),
                ],
              );
            },
            context: context,
          );
        });
      },
    );
  }
}

class TopicCard extends StatefulWidget {
  const TopicCard({
    Key key,
    this.child,
    this.nickname,
    this.topic,
    this.isDevice,
  }) : super(key: key);

  final Widget child;
  final String nickname;
  final String topic;

  final bool isDevice;

  @override
  _TopicCardState createState() {
    return new _TopicCardState();
  }
}

class _TopicCardState extends State<TopicCard> {
  TextEditingController inputNicknameController = new TextEditingController();

  var _nickname;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nickname = widget.nickname;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            child: Card(
              child: FlatButton(
                child: ListTile(
                  title: Text(
                    _nickname,
                    style: TextStyle(fontSize: 20.0),
                  ),
                  subtitle: Text(widget.isDevice
                      ? "Your device topic is " + widget.topic
                      : widget.topic),
                ),
                onPressed: () {
                  Navigator.of(context).push(new PageRouteBuilder(pageBuilder:
                      (BuildContext context, Animation<double> animation,
                          Animation<double> secondaryAnimation) {
                    return new DetailsPage(
                      topic: widget.topic,
                      nickname: _nickname,
                    );
                  }, transitionsBuilder: (
                    BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child,
                  ) {
                    // 添加一个平移动画
                    return createTransition(animation, child);
                  }));
                },
              ),
            ),
            onLongPress: () {
              showDialog<Null>(
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: Text('Modify the nick name'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: inputNicknameController,
                          decoration: InputDecoration(
                              hintText: "Please input the modified nick name"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FlatButton(
                          child: Text('Confirm'),
                          onPressed: () {
                            setState(() {
                              Navigator.of(context).pop();
                              _nickname = inputNicknameController.text;
                              inputNicknameController.clear();
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
                context: context,
              );
            },
          ),
          flex: 2,
        ),
      ],
    );
  }
}

SlideTransition createTransition(Animation<double> animation, Widget child) {
  return new SlideTransition(
    position: new Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(animation),
    child: child,
  );
}
