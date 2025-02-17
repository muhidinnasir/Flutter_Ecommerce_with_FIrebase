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
import 'package:firekart/core/extentions/list_extention.dart';
import 'package:firekart/data/mapper/data_mapper.dart';
import 'package:firekart/data/service/sms_service.dart';
import 'package:firekart/domain/models/account_details_model.dart';
import 'package:firekart/domain/models/cart_model.dart';
import 'package:firekart/domain/models/order_model.dart';
import 'package:firekart/domain/models/product_model.dart';
import 'package:firekart/domain/repository/firebase_repository.dart';
import 'package:injectable/injectable.dart' hide Order;

import '../service/firebase_service.dart';

@Singleton(as: FirebaseRepository)
class FirebaseRepositoryImpl extends FirebaseRepository {
  final DataMapper _mapper;
  final FirebaseService _firebaseService;
  final SmsService _smsService;

  FirebaseRepositoryImpl(this._mapper, this._firebaseService, this._smsService);

  @override
  Future<AccountDetails> fetchUserDetails() async {
    final accounts = await _firebaseService.fetchUserDetails();
    return _mapper.accountDetailsFromModel(accounts);
  }

  @override
  Future<void> addUserDetails(AccountDetails accountDetails) {
    return _firebaseService
        .addUserDetails(_mapper.accountDetailsToModel(accountDetails));
  }

  @override
  Future<List<Order>> getAllOrders() async {
    final orders = await _firebaseService.getAllOrders();
    return orders.mapToList(_mapper.orderFromModel);
  }

  @override
  Future<List<Product>> getAllProducts({
    String? condition,
    required bool all,
  }) async {
    final products = await _firebaseService.getAllProducts();
    return products.mapToList(_mapper.productFromModel);
  }

  @override
  Stream<List<Cart>> listenToCart() {
    return _firebaseService
        .cartStatusListen()
        .map((event) => event.mapToList(_mapper.cartFromModel));
  }

  @override
  Future<bool> placeOrder(Order order) async {
    await _firebaseService.placeOrder(_mapper.orderToModel(order));
    await _firebaseService.emptyCart();
    return true;
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final products = await _firebaseService.searchProducts(query);
    return products.mapToList(_mapper.productFromModel);
  }

  @override
  Stream<AccountDetails> streamUserDetails() {
    return _firebaseService
        .streamUserDetails()
        .map(_mapper.accountDetailsFromModel);
  }

  @override
  Future<bool> addProductToCart(Cart cart) async{
    await _firebaseService.addProductToCart(_mapper.carToModel(cart));
    return true;
  }

  @override
  Future<void> delProductFromCart(String productId) {
    return _firebaseService.delProductFromCart(productId);
  }

  @override
  String? getPhoneNumber() {
    return _firebaseService.getPhoneNumber();
  }

  @override
  Future<int> checkItemInCart(String productId) {
    return _firebaseService.checkItemInCart(productId);
  }

  @override
  Future<bool> checkUserDetail() {
    return _firebaseService.checkUserDetail();
  }

  @override
  dynamic getCurrentUser() {
    return _firebaseService.getCurrentUser();
  }

  @override
  Future<void> logoutUser() {
    return _firebaseService.logoutUser();
  }

  @override
  Future<void> setAccountDetails({String? displayName, String? photoUrl}) {
    return _firebaseService.setAccountDetails(
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  @override
  Future<void> loginWithOtp(
    String smsCode,
    void Function(String error) onError,
  ) {
    return _smsService.loginWithOtp(smsCode, onError);
  }

  @override
  Future<bool> sendCode(
    String phoneNumber,
    void Function(String error) onError,
  ) {
    return _smsService.sendCode(phoneNumber, onError);
  }
}
