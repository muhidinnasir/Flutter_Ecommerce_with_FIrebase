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
import 'package:firekart/domain/models/product_model.dart';

import '../../../routes/app_router.gr.dart';
import '../../../routes/navigation_handler.dart';
import '../../../widgets/commom_search_text_field.dart';
import '../../../widgets/common_app_loader.dart';
import '../../../widgets/product_card.dart';
import '../state/product_search_state.dart';
import '../view_model/product_search_viewmodel.dart';

@RoutePage()
class SearchItemScreen extends StatefulWidget {
  const SearchItemScreen({Key? key}) : super(key: key);

  @override
  State createState() => _SearchItemScreenState();
}

class _SearchItemScreenState extends State<SearchItemScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseView<ProductSearchViewModel, ProductSearchState>(
      builder: (BuildContext context, viewmodel, ProductSearchState state) {
        return Scaffold(
          appBar: CommonSearchBar(
            hintText: Localization.value.searchItems,
            onTextChanged: (String value) {
              viewmodel.searchProduct(value);
            },
          ),
          body: Builder(
            builder: (context) {
              if (state.loading) {
                return const Center(
                  child: CommonAppLoader(),
                );
              } else {
                return productView(state.productList);
              }
            },
          ),
        );
      },
    );
  }

  Widget productView(List<Product> productList) {
    return GridView.count(
      padding: const EdgeInsets.only(bottom: 10, right: 16, left: 16, top: 20),
      crossAxisCount: 3,
      shrinkWrap: true,
      mainAxisSpacing: 10,
      childAspectRatio: 0.7,
      crossAxisSpacing: 10,
      children: List.generate(
        productList.length,
        (index) => ProductCard(productModelToArgs(productList[index])),
      ),
    );
  }

  ProductCardArgs productModelToArgs(Product productModel) {
    return ProductCardArgs(
      image: productModel.image,
      name: productModel.name,
      currency: productModel.currency,
      onTap: () {
        NavigationHandler.navigateTo<void>(
          ProductDetailRoute(
            product: productModel,
          ),
        );
      },
      actualPrice: productModel.actualPrice,
      currentPrice: productModel.currentPrice,
      quantityPerUnit: productModel.quantityPerUnit,
      unit: productModel.unit,
    );
  }
}
