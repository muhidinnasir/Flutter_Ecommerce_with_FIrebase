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
import 'package:firekart/core/localization/localization.dart';
import 'package:firekart/core/message_handler/message_handler.dart';
import 'package:firekart/core/state_manager/view_model.dart';
import 'package:firekart/core/utils/connectivity.dart';
import 'package:firekart/domain/models/account_details_model.dart';
import 'package:firekart/domain/models/cart_model.dart';
import 'package:firekart/domain/models/order_model.dart';
import 'package:firekart/domain/usecases/add_product_to_cart_usecase.dart';
import 'package:firekart/domain/usecases/delete_product_from_cart_usecase.dart';
import 'package:firekart/domain/usecases/get_cart_status_use_case.dart';
import 'package:firekart/domain/usecases/place_order_usecase.dart';
import 'package:firekart/domain/usecases/stream_account_details_usecase.dart';
import 'package:injectable/injectable.dart' hide Order;

import '../../../routes/app_router.gr.dart';
import '../../../routes/navigation_handler.dart';
import '../state/cart_state.dart';

@injectable
class CartViewModel extends ViewModel<CartState> {
  CartViewModel(
    this._productAddToCartUseCase,
    this._productDeleteCartUseCase,
    this._placeOrderUseCase,
    this._accountDetailsUseCaseUseCase,
    this._getCartStatusUseCase,
  ) : super(const CartState());

  AccountDetails? accountDetails;

  final ProductAddToCartUseCase _productAddToCartUseCase;
  final ProductDeleteCartUseCase _productDeleteCartUseCase;
  final PlaceOrderUseCase _placeOrderUseCase;
  final StreamAccountDetailsUseCaseUseCase _accountDetailsUseCaseUseCase;
  final GetCartStatusUseCase _getCartStatusUseCase;

  void initCartValues(num cartValue) {
    state = state.copyWith(cartValue: cartValue as int);
  }

  int get noOfItemsInCart => state.cartList.length;

  num get priceInCart {
    num price = 0;
    List.generate(state.cartList.length, (index) {
      price = price +
          (state.cartList[index].currentPrice *
              state.cartList[index].numOfItems);
    });
    return price;
  }

  String get currency => noOfItemsInCart > 0 ? state.cartList[0].currency : '';

  // set cartItems(List<Cart> value) {
  //   state = state.copyWith(cartList: value);
  // }

  Future<void> placeOrder() async {
    if (state.selectedAddress == null) {
      MessageHandler.showSnackBar(title: Localization.value.noAddressSelected);
      return;
    }
    state = state.copyWith(orderInProgress: true);
    if (await ConnectionStatus.getInstance().checkConnection()) {
      try {
        await _placeOrderUseCase.execute(
          _orderFromCartList(state.cartList, state.selectedAddress!),
        );
        if (NavigationHandler.canNavigateBack()) {
          await NavigationHandler.navigateTo<void>(
            const MyOrdersRoute(),
          );
        }
      } catch (e) {
        MessageHandler.showSnackBar(title: e.toString());
      }
    } else {
      MessageHandler.showSnackBar(
        title: Localization.value.connectionNotAvailable,
      );
    }
    state = state.copyWith(orderInProgress: false);
  }

  Order _orderFromCartList(List<Cart> cartModel, Address orderAddress) {
    final cartItems = cartModel;

    List<OrderItem> getOrderItems() =>
        List<OrderItem>.generate(cartItems.length, (index) {
          final cartModel = cartItems[index];

          return OrderItem(
            name: cartModel.name,
            productId: cartModel.productId,
            currency: cartModel.currency,
            price: cartModel.currentPrice,
            unit: cartModel.unit,
            image: cartModel.image,
            noOfItems: cartModel.numOfItems,
          );
        });

    final orderModel = Order(
      orderId:
          '${cartModel.priceInCart}${DateTime.now().millisecondsSinceEpoch}',
      orderItems: getOrderItems(),
      paymentId: 'response.paymentId!',
      signature: 'response.signature!',
      price: cartModel.priceInCart,
      orderAddress: orderAddress,
      currency: cartModel.first.currency,
      orderedAt: DateTime.now().toString(),
      orderStatus: 'Ordered',
    );
    return orderModel;
  }

  void selectOrChangeAddress() {
    if (accountDetails == null) return;
    if (state.selectedAddress == null) {
      NavigationHandler.navigateTo<void>(
        AddAddressRoute(
          newAddress: true,
          accountDetails: accountDetails!,
        ),
      );
    } else {
      NavigationHandler.navigateTo<Address?>(
        MyAddressRoute(
          selectedAddress: true,
        ),
      ).then((value) {
        if (value != null && value.runtimeType is Address) {
          state = state.copyWith(selectedAddress: value);
        }
      });
    }
  }

  void addAccountDetails(AccountDetails? accountDetails) {
    if (accountDetails != null) {
      Address? address;
      List.generate(accountDetails.addresses.length, (int index) {
        final add = accountDetails.addresses[index];
        if (add.isDefault) {
          address = add;
        }
      });

      if (address == null && accountDetails.addresses.isNotEmpty) {
        address = accountDetails.addresses[0];
      }

      if (accountDetails.addresses.isNotEmpty) {
        if (state.selectedAddress == null) {
          state = state.copyWith(selectedAddress: address);
        }
      }
    }
  }

  Future<void> updateCartValues(int index, bool shouldIncrease) async {
    final cart = state.cartList[index];

    final newCartValue =
        shouldIncrease ? cart.numOfItems + 1 : cart.numOfItems - 1;

    state = state.copyWith(
      cartItemDataLoading: CartDataLoading(index: index, isLoading: true),
    );

    if (newCartValue > 0) {
      if (!(await ConnectionStatus.getInstance().checkConnection())) {
        MessageHandler.showSnackBar(
          title: Localization.value.connectionNotAvailable,
        );
        return;
      }

      cart.numOfItems = newCartValue;
      List<Cart> updatedCartList = List.from(state.cartList);
      updatedCartList[index] = cart;
      state = state.copyWith(cartList: updatedCartList);

      await _productAddToCartUseCase.execute(cart).then((value) {
        state = state.copyWith(cartList: state.cartList);
      }).catchError((e) {
        MessageHandler.showSnackBar(title: e.toString());
      });
    } else {
      await deleteItem(index, deleteExternally: false);
    }
    state = state.copyWith(
      cartItemDataLoading: CartDataLoading(index: index),
    );
  }

  Future<void> deleteItem(int index, {bool deleteExternally = true}) async {
    final cartModel = state.cartList[index];
    if (deleteExternally) {
      state = state.copyWith(
        cartItemDataLoading: CartDataLoading(index: index, deleteLoading: true),
      );
    }
    if (!(await ConnectionStatus.getInstance().checkConnection())) {
      MessageHandler.showSnackBar(
        title: Localization.value.connectionNotAvailable,
      );
      return;
    }
    await _productDeleteCartUseCase.execute(cartModel.productId).then((value) {
      // state.cartList.removeAt(index);
      state = state.copyWith(cartList: state.cartList);
    }).catchError((e) {
      MessageHandler.showSnackBar(title: e.toString());
    });
    state = state.copyWith(
      cartItemDataLoading: CartDataLoading(index: index),
    );
  }

  void init() {
    _getCartStatusUseCase.execute().listen((event) {
      state = state.copyWith(cartList: event);
    });
    _accountDetailsUseCaseUseCase.execute().listen(addAccountDetails);
  }
}

extension CartStatus on List<Cart> {
  int get noOfItemsInCart => length;

  num get priceInCart {
    num price = 0;
    List.generate(length, (index) {
      price = price + (this[index].currentPrice * this[index].numOfItems);
    });
    return price;
  }

  String get currency => noOfItemsInCart > 0 ? this[0].currency : '';
}
