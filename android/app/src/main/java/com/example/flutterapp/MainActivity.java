package com.example.flutterapp;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.SensorsPlugin;
import io.flutter.plugin.common.PluginRegistry;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        SensorsPlugin.registerWith(this.registrarFor("io.flutter.plugins.SensorsPlugin"));
    }
}
