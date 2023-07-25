import 'package:dashclicker/model/past_purchase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IAPState {
  final bool isLoggedIn;
  final User? user;
  final bool hasActiveSubscription;
  final bool hasUpgrade;
  final List<PastPurchase> purchases;

  IAPState({
    required this.isLoggedIn,
    required this.user,
    required this.hasActiveSubscription,
    required this.hasUpgrade,
    required this.purchases,
  });
}
