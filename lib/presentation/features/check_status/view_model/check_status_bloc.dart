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
import 'package:firekart/core/state_manager/view_model.dart';
import 'package:firekart/domain/usecases/get_user_data_status_usecase.dart';
import 'package:firekart/domain/usecases/get_user_logged_in_status.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:injectable/injectable.dart';

import '../../../routes/app_router.gr.dart';
import '../../../routes/navigation_handler.dart';

@injectable
class CheckStatusViewModel extends ViewModel<int> {
  CheckStatusViewModel(
    this._getUserLoggedInStatusUseCase,
    this._getUserDataStatusUseCase,
  ) : super(0);
  final GetUserLoggedInStatusUseCase _getUserLoggedInStatusUseCase;
  final GetUserDataStatusUseCase _getUserDataStatusUseCase;

  Future<void> checkStatus(bool checkForAccountStatusOnly) async {
    Future.delayed(
      Duration(seconds: checkForAccountStatusOnly ? 2 : 0),
      () async {
        final status = _getUserLoggedInStatusUseCase.execute();
        if (checkForAccountStatusOnly || status) {
          final isUserDataPresent = await _getUserDataStatusUseCase.execute();
          if (isUserDataPresent) {
            await NavigationHandler.navigateTo<void>(
              const HomeRoute(),
              navigationType: NavigationType.pushReplacement,
            );
          } else {
            await NavigationHandler.navigateTo<void>(
              AddUserDetailRoute(newAddress: true),
              navigationType: NavigationType.pushReplacement,
            );
          }
        } else {
          await NavigationHandler.navigateTo<void>(
            const LoginRoute(),
            navigationType: NavigationType.pushReplacement,
          );
        }
      },
    );
  }
}
