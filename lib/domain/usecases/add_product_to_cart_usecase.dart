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
import 'package:firekart/domain/models/cart_model.dart';
import 'package:firekart/domain/repository/firebase_repository.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:injectable/injectable.dart';

@injectable
class ProductAddToCartUseCase {
  final FirebaseRepository _firebaseRepository;

  ProductAddToCartUseCase(this._firebaseRepository);

  Future<void> execute(Cart cart) {
    return _firebaseRepository.addProductToCart(cart);
  }
}
