import 'package:flutter/material.dart';

import 'app/app.dart';
import 'injection/injection_container.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = AppDependencies.create();

  runApp(MyApp(dependencies: dependencies));
}
