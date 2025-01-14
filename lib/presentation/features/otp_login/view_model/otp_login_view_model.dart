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

import 'package:firekart/core/message_handler/message_handler.dart';
import 'package:firekart/core/state_manager/view_model.dart';
import 'package:firekart/domain/usecases/send_otp_usecase.dart';
import 'package:firekart/presentation/routes/app_router.gr.dart';
import 'package:firekart/presentation/routes/navigation_handler.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:injectable/injectable.dart';

import '../state/otp_login_state.dart';

@injectable
class OtpLoginViewModel extends ViewModel<OtpLoginState> {
  OtpLoginViewModel(this._sendOTPUseCase) : super(const OtpLoginState());
  final SendOTPUseCase _sendOTPUseCase;

  void validateButton(String otp) {
    if (otp.length == 6) {
      state = state.copyWith(isButtonEnabled: true);
    } else {
      state = state.copyWith(isButtonEnabled: false);
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    await _sendOTPUseCase.execute(
      phoneNumber: phoneNumber,
      onSuccess: (auth) {
        state = state.copyWith(otp: '******');
      },
      onError: (value) {
        MessageHandler.showSnackBar(title: value);
        state = state.copyWith(error: value);
      },
    );
  }

  void loginWithOtp(String smsCode, bool isResend) {
    if (state.resendOtpLoading || state.confirmOtpLoading) {
      return;
    }
    state = state.copyWith(
      confirmOtpLoading: !isResend,
      resendOtpLoading: isResend,
    );
    _sendOTPUseCase.loginWithOtp(
      smsCode,
      (error) {},
    ).then((value) {
      NavigationHandler.navigateTo<void>(
        CheckStatusRoute(checkForAccountStatusOnly: true),
        navigationType: NavigationType.pushAndPopUntil,
      );
    });
  }
}
