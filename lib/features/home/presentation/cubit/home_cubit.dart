import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/features/home/domain/usecases/get_home.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getHome) : super(const HomeInitial());

  final GetHome _getHome;

  Future<void> fetchHome() async {
    emit(const HomeLoading());
    await refresh();
  }

  Future<void> refresh() async {
    final result = await _getHome();
    if (isClosed) return;
    result.fold((failure) {
      if (failure is! CancelledFailure) emit(HomeError(failure));
    }, (data) => emit(HomeLoaded(data)));
  }
}
