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
import 'package:firekart/core/message_handler/message_handler.dart';
import 'package:firekart/core/state_manager/view_model.dart';
import 'package:firekart/domain/models/account_details_model.dart';
import 'package:firekart/domain/usecases/get_account_details_usecase.dart';
import 'package:firekart/domain/usecases/set_account_details_usecase.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:injectable/injectable.dart';

import '../state/my_address_state.dart';

@injectable
class MyAddressViewModel extends ViewModel<MyAddressState> {
  MyAddressViewModel(
    this._getAccountDetailsUseCase,
    this._setAccountDetailsUseCase,
  ) : super(const MyAddressState());

  final GetAccountDetailsUseCase _getAccountDetailsUseCase;
  final SetAccountDetailsUseCase _setAccountDetailsUseCase;

  Future<void> listenToAccountDetails(AccountDetails accountDetails) async {
    setAddress(accountDetails);
  }

  void setAddress(AccountDetails accountDetails) {
    final List<AddressCardState> cardStates = [];

    for (int i = 0; i < accountDetails.addresses.length; i++) {
      cardStates.add(
        AddressCardState(address: accountDetails.addresses[i], index: i),
      );
    }
    state = state.copyWith(
      accountDetails: accountDetails,
      addressStates: cardStates,
      screenLoading: false,
    );
  }

  Future<void> fetchAccountDetails() async {
    state = state.copyWith(screenLoading: true);
    final AccountDetails accountDetails =
        await _getAccountDetailsUseCase.execute();
    accountDetails.addresses = accountDetails.addresses.reversed.toList();
    setAddress(accountDetails);
    state = state.copyWith(screenLoading: false);
  }

  void deleteAddress(int index) {
    void updateLoading(bool value) {
      final addresses = state.addressStates;
      final address =
          addresses[index].copyWith(index: index, editLoading: value);
      addresses[index] = address;
      state = state.copyWith(addressStates: addresses);
    }

    updateLoading(true);

    state.accountDetails!.addresses.remove(state.addressStates[index].address);
    _saveData(state.accountDetails!);
    state = state;

    updateLoading(false);
  }

  void setAsDefault(int index) {
    final addresses = state.addressStates;
    final address =
        addresses[index].copyWith(index: index, setDefaultLoading: true);
    addresses[index] = address;
    state = state.copyWith(addressStates: addresses);

    state.accountDetails!.addresses[index].isDefault = true;

    List.generate(state.accountDetails!.addresses.length, (index) {
      if (index != index) {
        state.accountDetails!.addresses[index].isDefault = false;
      }
    });
    _saveData(state.accountDetails!);
  }

  void _saveData(AccountDetails accountDetails) {
    _setAccountDetailsUseCase.execute(accountDetails).then((value) {
      fetchAccountDetails();
    }).catchError(( e) {
      MessageHandler.showSnackBar(title: e.toString());
    });
  }
}
