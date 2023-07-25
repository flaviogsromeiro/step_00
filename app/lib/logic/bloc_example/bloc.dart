// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../repo/iap_repo.dart';
// import 'bloc_event.dart';
// import 'bloc_state.dart';

// class IAPBloc extends Bloc<IAPEvent, IAPState> {
//   final IAPRepo iapRepo;

//   IAPBloc(this.iapRepo) : super(IAPState(
//       isLoggedIn: false,
//       user: null,
//       hasActiveSubscription: false,
//       hasUpgrade: false,
//       purchases: [],
//     )) {
//     // Inicie a escuta das mudanças do login.
//     _initLoginListener();
//   }

//   void _initLoginListener() {
//     iapRepo.listenToLogin();
//     iapRepo.addListener(() {
//       add(UpdatePurchasesEvent());
//     });
//   }

//   @override
//   Stream<IAPState> mapEventToState(IAPEvent event) async* {
//     if (event is UpdatePurchasesEvent) {
//       yield _mapUpdatePurchasesToState(state);
//     }
//     // Adicione mais lógica para outros eventos, se necessário.
//   }

//   IAPState _mapUpdatePurchasesToState(IAPState currentState) {
//     return IAPState(
//       isLoggedIn: iapRepo.isLoggedIn,
//       user: iapRepo.user,
//       hasActiveSubscription: iapRepo.hasActiveSubscription,
//       hasUpgrade: iapRepo.hasUpgrade,
//       purchases: iapRepo.purchases,
//     );
//   }
// }
