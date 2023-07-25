// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';

// import '../constants.dart';
// import '../main.dart';
// import '../model/purchasable_product.dart';
// import '../model/store_state.dart';
// import '../repo/iap_repo.dart';
// import 'dash_counter.dart';
// import 'firebase_notifier.dart';

// // Bloc Events
// abstract class DashPurchasesEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class LoadPurchasesEvent extends DashPurchasesEvent {}

// class BuyProductEvent extends DashPurchasesEvent {
//   final PurchasableProduct product;

//   BuyProductEvent(this.product);

//   @override
//   List<Object?> get props => [product];
// }

// // Bloc States
// abstract class DashPurchasesState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class DashPurchasesInitialState extends DashPurchasesState {}

// class DashPurchasesLoadingState extends DashPurchasesState {}

// class DashPurchasesAvailableState extends DashPurchasesState {
//   final List<PurchasableProduct> products;

//   DashPurchasesAvailableState(this.products);

//   @override
//   List<Object?> get props => [products];
// }

// class DashPurchasesNotAvailableState extends DashPurchasesState {}

// // Bloc
// class DashPurchasesBloc extends Bloc<DashPurchasesEvent, DashPurchasesState> {
//   final DashCounter counter;
//   final FirebaseNotifier firebaseNotifier;
//   final IAPRepo iapRepo;

//   late StreamSubscription<List<PurchaseDetails>> _subscription;
//   bool beautifiedDashUpgrade = false;
//   final iapConnection = IAPConnection.instance;

//   DashPurchasesBloc(
//     this.counter,
//     this.firebaseNotifier,
//     this.iapRepo,
//   ) : super(DashPurchasesInitialState()) {
//     final purchaseUpdated = iapConnection.purchaseStream;
//     _subscription = purchaseUpdated.listen(
//       _onPurchaseUpdate,
//       onDone: _updateStreamOnDone,
//       onError: _updateStreamOnError,
//     );
//     iapRepo.addListener(purchasesUpdate);
//     add(LoadPurchasesEvent());
//   }

//   @override
//   Future<void> close() {
//     iapRepo.removeListener(purchasesUpdate);
//     _subscription.cancel();
//     return super.close();
//   }

//   @override
//   Stream<DashPurchasesState> mapEventToState(DashPurchasesEvent event) async* {
//     if (event is LoadPurchasesEvent) {
//       yield* _mapLoadPurchasesEventToState();
//     } else if (event is BuyProductEvent) {
//       yield* _mapBuyProductEventToState(event);
//     }
//   }

//   Stream<DashPurchasesState> _mapLoadPurchasesEventToState() async* {
//     yield DashPurchasesLoadingState();

//     final available = await iapConnection.isAvailable();
//     if (!available) {
//       yield DashPurchasesNotAvailableState();
//       return;
//     }

//     const ids = <String>{
//       storeKeyConsumable,
//       storeKeySubscription,
//       storeKeyUpgrade,
//     };
//     final response = await iapConnection.queryProductDetails(ids);
//     final products =
//         response.productDetails.map((e) => PurchasableProduct(e)).toList();

//     yield DashPurchasesAvailableState(products);
//   }

//   Stream<DashPurchasesState> _mapBuyProductEventToState(
//       BuyProductEvent event) async* {
//     final product = event.product;
//     final purchaseParam = PurchaseParam(productDetails: product.productDetails);

//     switch (product.id) {
//       case storeKeyConsumable:
//         await iapConnection.buyConsumable(purchaseParam: purchaseParam);
//         break;
//       case storeKeySubscription:
//       case storeKeyUpgrade:
//         await iapConnection.buyNonConsumable(purchaseParam: purchaseParam);
//         break;
//       default:
//         throw ArgumentError.value(
//             product.productDetails, '${product.id} is not a known product');
//     }
//   }

//   Future<void> _onPurchaseUpdate(
//       List<PurchaseDetails> purchaseDetailsList) async {
//     for (var purchaseDetails in purchaseDetailsList) {
//       await _handlePurchase(purchaseDetails);
//     }
//     add(LoadPurchasesEvent());
//   }

//   Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
//     if (purchaseDetails.status == PurchaseStatus.purchased) {
//       // Send to server
//       var validPurchase = await _verifyPurchase(purchaseDetails);

//       if (validPurchase) {
//         // Apply changes locally
//         switch (purchaseDetails.productID) {
//           case storeKeySubscription:
//             counter.applyPaidMultiplier();
//             break;
//           case storeKeyConsumable:
//             counter.addBoughtDashes(2000);
//             break;
//           case storeKeyUpgrade:
//             beautifiedDashUpgrade = true;
//             break;
//         }
//       }
//     }

//     if (purchaseDetails.pendingCompletePurchase) {
//       await iapConnection.completePurchase(purchaseDetails);
//     }
//   }

//   Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
//     final url = Uri.parse('http://$serverIp:8080/verifypurchase');
//     const headers = {
//       'Content-type': 'application/json',
//       'Accept': 'application/json',
//     };
//     final response = await http.post(
//       url,
//       body: jsonEncode({
//         'source': purchaseDetails.verificationData.source,
//         'productId': purchaseDetails.productID,
//         'verificationData':
//             purchaseDetails.verificationData.serverVerificationData,
//         'userId': firebaseNotifier.user?.uid,
//       }),
//       headers: headers,
//     );
//     if (response.statusCode == 200) {
//       print('Successfully verified purchase');
//       return true;
//     } else {
//       print('failed request: ${response.statusCode} - ${response.body}');
//       return false;
//     }
//   }

//   void _updateStreamOnDone() {
//     _subscription.cancel();
//   }

//   void _updateStreamOnError(dynamic error) {
//     print(error);
//   }

//   void purchasesUpdate() {
//     var subscriptions = <PurchasableProduct>[];
//     var upgrades = <PurchasableProduct>[];

//     final state = state;
//     if (state is DashPurchasesAvailableState) {
//       // Get a list of purchasable products for the subscription and upgrade.
//       // This should be 1 per type.
//       if (state.products.isNotEmpty) {
//         subscriptions = state.products
//             .where(
//                 (element) => element.productDetails.id == storeKeySubscription)
//             .toList();
//         upgrades = state.products
//             .where((element) => element.productDetails.id == storeKeyUpgrade)
//             .toList();
//       }
//     }
//   }
// }
