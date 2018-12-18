import 'dart:async';
import 'package:flutter/services.dart';

const EventChannel _accelerometerEventChannel =
EventChannel('plugins.flutter.io/sensors/accelerometer');

const EventChannel _userAccelerometerEventChannel =
EventChannel('plugins.flutter.io/sensors/user_accel');

const EventChannel _gyroscopeEventChannel =
EventChannel('plugins.flutter.io/sensors/gyroscope');

const EventChannel _gravityEventChannel =
EventChannel('plugins.flutter.io/sensors/gravity');

const EventChannel _rotationEventChannel =
EventChannel('plugins.flutter.io/sensors/rotation');

class AccelerometerEvent {
  /// Acceleration force along the x axis (including gravity) measured in m/s^2.
  final double x;

  /// Acceleration force along the y axis (including gravity) measured in m/s^2.
  final double y;

  /// Acceleration force along the z axis (including gravity) measured in m/s^2.
  final double z;

  AccelerometerEvent(this.x, this.y, this.z);

  @override
  String toString() => '[AccelerometerEvent (x: $x, y: $y, z: $z)]';
}

class GyroscopeEvent {
  /// Rate of rotation around the x axis measured in rad/s.
  final double x;

  /// Rate of rotation around the y axis measured in rad/s.
  final double y;

  /// Rate of rotation around the z axis measured in rad/s.
  final double z;

  GyroscopeEvent(this.x, this.y, this.z);

  @override
  String toString() => '[GyroscopeEvent (x: $x, y: $y, z: $z)]';
}

class UserAccelerometerEvent {
  /// Acceleration force along the x axis (excluding gravity) measured in m/s^2.
  final double x;

  /// Acceleration force along the y axis (excluding gravity) measured in m/s^2.
  final double y;

  /// Acceleration force along the z axis (excluding gravity) measured in m/s^2.
  final double z;

  UserAccelerometerEvent(this.x, this.y, this.z);

  @override
  String toString() => '[UserAccelerometerEvent (x: $x, y: $y, z: $z)]';
}

class GravityEvent {
  /// Acceleration force along the x axis (excluding gravity) measured in m/s^2.
  final double x;

  /// Acceleration force along the y axis (excluding gravity) measured in m/s^2.
  final double y;

  /// Acceleration force along the z axis (excluding gravity) measured in m/s^2.
  final double z;

  GravityEvent(this.x, this.y, this.z);

  @override
  String toString() => '[GravityEvent (x: $x, y: $y, z: $z)]';
}

class RotationEvent {
  /// Acceleration force along the x axis (excluding gravity) measured in m/s^2.
  final double x;

  /// Acceleration force along the y axis (excluding gravity) measured in m/s^2.
  final double y;

  /// Acceleration force along the z axis (excluding gravity) measured in m/s^2.
  final double z;

  RotationEvent(this.x, this.y, this.z);

  @override
  String toString() => '[RotationEvent (x: $x, y: $y, z: $z)]';
}

AccelerometerEvent _listToAccelerometerEvent(List<double> list) {
  return new AccelerometerEvent(list[0], list[1], list[2]);
}

UserAccelerometerEvent _listToUserAccelerometerEvent(List<double> list) {
  return new UserAccelerometerEvent(list[0], list[1], list[2]);
}

GyroscopeEvent _listToGyroscopeEvent(List<double> list) {
  return new GyroscopeEvent(list[0], list[1], list[2]);
}

GravityEvent _listToGravityEvent(List<double> list) {
  return new GravityEvent(list[0], list[1], list[2]);
}

RotationEvent _listToRotationEvent(List<double> list) {
  return new RotationEvent(list[0], list[1], list[2]);
}

Stream<AccelerometerEvent> _accelerometerEvents;
Stream<GyroscopeEvent> _gyroscopeEvents;
Stream<UserAccelerometerEvent> _userAccelerometerEvents;
Stream<GravityEvent> _gravityEvents;
Stream<RotationEvent> _rotationEvents;

/// A broadcast stream of events from the device accelerometer.
Stream<AccelerometerEvent> get accelerometerEvents {
  if (_accelerometerEvents == null) {
    _accelerometerEvents = _accelerometerEventChannel
        .receiveBroadcastStream()
        .map(
            (dynamic event) => _listToAccelerometerEvent(event.cast<double>()));
  }
  return _accelerometerEvents;
}

/// A broadcast stream of events from the device gyroscope.
Stream<GyroscopeEvent> get gyroscopeEvents {
  if (_gyroscopeEvents == null) {
    _gyroscopeEvents = _gyroscopeEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _listToGyroscopeEvent(event.cast<double>()));
  }
  return _gyroscopeEvents;
}

/// Events from the device accelerometer with gravity removed.
Stream<UserAccelerometerEvent> get userAccelerometerEvents {
  if (_userAccelerometerEvents == null) {
    _userAccelerometerEvents = _userAccelerometerEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) =>
        _listToUserAccelerometerEvent(event.cast<double>()));
  }
  return _userAccelerometerEvents;
}

Stream<GravityEvent> get gravityEvents {
  if (_gravityEvents == null) {
    _gravityEvents = _gravityEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) =>
        _listToGravityEvent(event.cast<double>()));
  }
  return _gravityEvents;
}

Stream<RotationEvent> get rotationEvents {
  if (_rotationEvents == null) {
    _rotationEvents = _rotationEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) =>
        _listToRotationEvent(event.cast<double>()));
  }
  return _rotationEvents;
}