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
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:firekart/core/localization/localization.dart';
import 'package:firekart/core/state_manager/base_view.dart';
import 'package:firekart/core/theme/theme_provider.dart';
import 'package:firekart/core/utils/validator.dart';
import 'package:firekart/domain/models/account_details_model.dart';

import '../../../res/colors.gen.dart';
import '../../../widgets/commom_text_field.dart';
import '../../../widgets/common_button.dart';
import '../state/add_address_state.dart';
import '../view_model/add_address_view_model.dart';

@RoutePage()
class AddAddressScreen extends StatelessWidget {
  AddAddressScreen(
    this.newAddress,
    this.accountDetails, {
    Key? key,
    this.editAddress,
  }) : super(key: key);
  final bool newAddress;
  final AccountDetails accountDetails;
  final Address? editAddress;

  final TextEditingController nameEditingController = TextEditingController();
  final TextEditingController emailEditingController = TextEditingController();
  final TextEditingController pincodeEditingController =
      TextEditingController();
  final TextEditingController addressEditingController =
      TextEditingController();
  final TextEditingController cityEditingController = TextEditingController();
  final TextEditingController stateEditingController = TextEditingController();
  final TextEditingController phoneEditingController = TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode pincodeFocusNode = FocusNode();
  final FocusNode addressFocusNode = FocusNode();
  final FocusNode cityFocusNode = FocusNode();
  final FocusNode stateFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final Validator validator = Validator();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BaseView<AddAddressViewModel, AddAddressState>(
      onViewModelReady: (viewModel) {
        if (editAddress != null) {
          nameEditingController.text = editAddress!.name;
          pincodeEditingController.text = editAddress!.pincode;
          addressEditingController.text = editAddress!.address;
          cityEditingController.text = editAddress!.city;
          phoneEditingController.text = editAddress!.phoneNumber;
          viewModel.setDefault(editAddress!.isDefault);
        }
      },
      builder: (context, viewModel, state) => Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: Text("${newAddress ? "Add" : "Edit"} Address"),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: newAddress,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        child: Text(
                          Localization.value.addNewAddress,
                          style: ThemeProvider.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    CustomTextField(
                      hint: Localization.value.name,
                      textEditingController: nameEditingController,
                      focusNode: nameFocusNode,
                      nextFocusNode: pincodeFocusNode,
                      validator: validator.validateName,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (val) {
                        FocusScope.of(context).requestFocus(pincodeFocusNode);
                      },
                      // containerHeight: 50,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextField(
                      hint: Localization.value.pincode,
                      textEditingController: pincodeEditingController,
                      focusNode: pincodeFocusNode,
                      nextFocusNode: addressFocusNode,
                      validator: validator.validatePinCode,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (val) {
                        FocusScope.of(context).requestFocus(addressFocusNode);
                      },
                      // containerHeight: 50,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextField(
                      hint: Localization.value.address,
                      textEditingController: addressEditingController,
                      focusNode: addressFocusNode,
                      nextFocusNode: cityFocusNode,
                      validator: (val) {
                        if ((val ?? '').isEmpty) {
                          return 'Address is Required';
                        } else {
                          return null;
                        }
                      },
                      textInputAction: TextInputAction.next,
                      onSubmitted: (val) {
                        FocusScope.of(context).requestFocus(cityFocusNode);
                      },
                      // containerHeight: 50,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextField(
                      hint: Localization.value.city,
                      textEditingController: cityEditingController,
                      focusNode: cityFocusNode,
                      nextFocusNode: stateFocusNode,
                      validator: (val) => validator.validateText(val, 'City'),
                      textInputAction: TextInputAction.next,
                      onSubmitted: (val) {
                        FocusScope.of(context).requestFocus(stateFocusNode);
                      },
                      // containerHeight: 50,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextField(
                      hint: Localization.value.state,
                      textEditingController: stateEditingController,
                      focusNode: stateFocusNode,
                      nextFocusNode: phoneFocusNode,
                      validator: (val) => validator.validateText(val, 'State'),
                      textInputAction: TextInputAction.next,
                      onSubmitted: (val) {
                        FocusScope.of(context).requestFocus(phoneFocusNode);
                      },
                      // containerHeight: 50,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextField(
                      hint: Localization.value.phoneNumber,
                      textEditingController: phoneEditingController,
                      focusNode: phoneFocusNode,
                      validator: validator.validateMobile,
                      keyboardType: TextInputType.phone,
                      onChanged: (val) {
                        if (validator.validateMobile(val) == null) {
                          FocusScope.of(context).requestFocus(FocusNode());
                        }
                      },
                      // containerHeight: 50,
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      children: [
                        StatefulBuilder(
                          builder: (BuildContext context,
                              void Function(void Function()) setState,) {
                            return Checkbox(
                              value: state.setAsDefault,
                              onChanged: (bool? value) {
                                if (value != null) {
                                  viewModel.setDefault(value);
                                }
                              },
                            );
                          },
                        ),
                        Text(
                          Localization.value.setAsDefaultCaps,
                          style: ThemeProvider.textTheme.bodyLarge,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    CommonButton(
                      title: Localization.value.save,
                      titleColor: AppColors.white,
                      height: 50,
                      replaceWithIndicator: state.buttonLoading,
                      margin: const EdgeInsets.only(bottom: 40),
                      onTap: () {
                        onButtonTap(viewModel, state);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onButtonTap(AddAddressViewModel viewModel, AddAddressState state) {
    if (_formKey.currentState!.validate()) {
      final address = Address(
        name: nameEditingController.text,
        address: addressEditingController.text,
        city: cityEditingController.text,
        isDefault: state.setAsDefault,
        pincode: pincodeEditingController.text,
        //todo add the country picker
        phoneNumber: '+91${phoneEditingController.text}',
        state: stateEditingController.text,
      );
      viewModel.saveAddress(accountDetails, address);
    }
  }
}
