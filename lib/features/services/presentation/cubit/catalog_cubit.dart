import 'package:booking_app/core/errors/failures.dart';
import 'package:booking_app/core/helpers/exception_handler.dart';
import 'package:booking_app/features/services/data/catalog_models.dart';
import 'package:booking_app/features/services/data/place_catalog_remote_datasource.dart';
import 'package:booking_app/features/services/models/service_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class ResourceState<T> {
  const ResourceState();
}

class ResourceLoading<T> extends ResourceState<T> {
  const ResourceLoading();
}

class ResourceLoaded<T> extends ResourceState<T> {
  const ResourceLoaded(this.data);
  final T data;
}

class ResourceError<T> extends ResourceState<T> {
  const ResourceError(this.failure);
  final Failure failure;
}

class ResourceCubit<T> extends Cubit<ResourceState<T>> {
  ResourceCubit(this._fetch) : super(const ResourceLoading());
  final Future<T> Function() _fetch;
  int _generation = 0;

  Future<void> load() async {
    final generation = ++_generation;
    emit(const ResourceLoading());
    try {
      final value = await _fetch();
      if (!isClosed && generation == _generation) emit(ResourceLoaded(value));
    } catch (error) {
      if (!isClosed && generation == _generation) {
        emit(ResourceError(mapExceptionToFailure(error)));
      }
    }
  }
}

class ServicesState {
  const ServicesState({
    this.items = const [],
    this.meta,
    this.loading = false,
    this.loadingMore = false,
    this.failure,
    this.query = const ServiceQuery(),
  });
  final List<ServiceModel> items;
  final PageMeta? meta;
  final bool loading;
  final bool loadingMore;
  final Failure? failure;
  final ServiceQuery query;
}

class ServicesCubit extends Cubit<ServicesState> {
  ServicesCubit(this._source, {ServiceQuery query = const ServiceQuery()})
    : super(ServicesState(query: query));

  final PlaceCatalogRemoteDatasource _source;
  int _generation = 0;

  Future<void> load({ServiceQuery? query}) async {
    final generation = ++_generation;
    final nextQuery = query ?? state.query;
    final previous = query == null ? state : null;
    emit(
      ServicesState(
        query: nextQuery,
        items: previous?.items ?? const [],
        meta: previous?.meta,
        loading: true,
      ),
    );
    try {
      final page = await _source.getServices(nextQuery);
      if (isClosed || generation != _generation) return;
      emit(ServicesState(items: page.items, meta: page.meta, query: nextQuery));
    } catch (error) {
      if (isClosed || generation != _generation) return;
      emit(
        ServicesState(
          query: nextQuery,
          items: previous?.items ?? const [],
          meta: previous?.meta,
          failure: mapExceptionToFailure(error),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || state.meta?.hasNextPage != true) {
      return;
    }
    final next = ServiceQuery(
      categoryId: state.query.categoryId,
      page: state.meta!.page + 1,
      perPage: state.query.perPage,
      q: state.query.q,
      staffId: state.query.staffId,
      maxDuration: state.query.maxDuration,
      sort: state.query.sort,
      order: state.query.order,
    );
    final generation = _generation;
    final previous = state;
    emit(
      ServicesState(
        items: previous.items,
        meta: previous.meta,
        query: previous.query,
        loadingMore: true,
      ),
    );
    try {
      final page = await _source.getServices(next);
      if (isClosed || generation != _generation) return;
      emit(
        ServicesState(
          items: [...previous.items, ...page.items],
          meta: page.meta,
          query: previous.query,
        ),
      );
    } catch (error) {
      if (isClosed || generation != _generation) return;
      emit(
        ServicesState(
          items: previous.items,
          meta: previous.meta,
          query: previous.query,
          failure: mapExceptionToFailure(error),
        ),
      );
    }
  }
}

class ReviewsState {
  const ReviewsState({
    this.items = const [],
    this.meta,
    this.loading = false,
    this.loadingMore = false,
    this.failure,
    this.average,
  });
  final List<Map<String, dynamic>> items;
  final PageMeta? meta;
  final bool loading;
  final bool loadingMore;
  final Failure? failure;
  final double? average;
}

class ReviewsCubit extends Cubit<ReviewsState> {
  ReviewsCubit(this._source, {this.serviceId}) : super(const ReviewsState());
  final PlaceCatalogRemoteDatasource _source;
  final int? serviceId;
  int _generation = 0;

  Future<ReviewPage> _getPage(int page) => serviceId == null
      ? _source.getPlaceReviews(page: page)
      : _source.getServiceReviews(serviceId!, page: page);

  Future<void> load() async {
    final generation = ++_generation;
    final previous = state;
    emit(
      ReviewsState(
        loading: true,
        items: previous.items,
        meta: previous.meta,
        average: previous.average,
      ),
    );
    try {
      final result = await _getPage(1);
      if (isClosed || generation != _generation) return;
      emit(
        ReviewsState(
          items: result.items,
          meta: result.meta,
          average: result.average,
        ),
      );
    } catch (error) {
      if (isClosed || generation != _generation) return;
      emit(
        ReviewsState(
          items: previous.items,
          meta: previous.meta,
          average: previous.average,
          failure: mapExceptionToFailure(error),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || state.meta?.hasNextPage != true) {
      return;
    }
    final previous = state;
    final generation = _generation;
    emit(
      ReviewsState(
        items: previous.items,
        meta: previous.meta,
        average: previous.average,
        loadingMore: true,
      ),
    );
    try {
      final result = await _getPage(previous.meta!.page + 1);
      if (isClosed || generation != _generation) return;
      emit(
        ReviewsState(
          items: [...previous.items, ...result.items],
          meta: result.meta,
          average: result.average ?? previous.average,
        ),
      );
    } catch (error) {
      if (isClosed || generation != _generation) return;
      emit(
        ReviewsState(
          items: previous.items,
          meta: previous.meta,
          average: previous.average,
          failure: mapExceptionToFailure(error),
        ),
      );
    }
  }
}
