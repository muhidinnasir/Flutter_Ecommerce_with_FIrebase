/*
 * ----------------------------------------------------------------------------
 *
 * This file is part of the FireKart open-source project, available at:
 * https://github.com/ashishrawat2911/firekart
 *
 * Created by: Ashish Rawat
 * ----------------------------------------------------------------------------
 *
 * Copyright (c) 2020 Ashish Rawat
 *
 * Licensed under the MIT License.
 *
 * ----------------------------------------------------------------------------
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firekart/core/di/di.dart';
import 'package:firekart/core/logger/app_logger.dart';
import 'package:firekart/core/state_manager/app_cubit_observer.dart';
import 'package:firekart/firebase_impl/crashlytics_service.dart';
import 'package:firekart/firebase_impl/firebase_impl.dart';

import 'app/app.dart';
import 'di/di.dart';

class Initializer {
  Initializer._();

  static Future<void> initialize(ValueChanged<Widget> onRun) async {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeFirebase();
    await registerDependencies();
    runZonedGuarded(
      () {
        runStateObserver();
        onRun(const App());
      },
      (error, stack) {
        AppLogger.log(
          'App level error',
          logType: LogType.error,
          error: error,
          stackTrace: stack,
        );
        inject<CrashlyticsService>().recordError(error, stack);
      },
      zoneSpecification: const ZoneSpecification(),
    );
  }
}
