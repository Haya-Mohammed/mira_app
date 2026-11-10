import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/features/home/data/models/home_data_model.dart';
import 'package:equatable/equatable.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded(this.data);

  final HomeDataModel data;

  @override
  List<Object?> get props => [data];
}

final class HomeError extends HomeState {
  const HomeError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
