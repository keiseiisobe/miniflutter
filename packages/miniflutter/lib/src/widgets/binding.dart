import 'package:flutter/material.dart';

void runApp(Widget app) {
  WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  _runWidget(app, binding);
}

void _runWidget(Widget app, WidgetsBinding binding) {
  binding
    ..scheduleAttachRootWidget(app)
    ..scheduleWarmUpFrame();
}
