part of '../screens/services_screen.dart';

class _ServicesView extends StatefulWidget {
  const _ServicesView({this.categoryName, this.currency});
  final String? categoryName;
  final String? currency;

  @override
  State<_ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends State<_ServicesView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _submit() {
    final cubit = context.read<ServicesCubit>();
    final q = cubit.state.query;
    cubit.load(
      query: ServiceQuery(
        categoryId: q.categoryId,
        q: _search.text,
        staffId: q.staffId,
        maxDuration: q.maxDuration,
        sort: q.sort,
        order: q.order,
      ),
    );
  }

  Future<void> _filters() async {
    final cubit = context.read<ServicesCubit>();
    final query = cubit.state.query;
    int? staffId = query.staffId;
    int? duration = query.maxDuration;
    String? sort = query.sort;
    String? order = query.order;
    final staffFuture = sl<PlaceCatalogRemoteDatasource>().getStaff();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              8,
              24,
              24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.text.filters,
                    style: context.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<StaffModel>>(
                    future: staffFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return snapshot.hasError
                            ? Text(context.text.noInternet)
                            : const LinearProgressIndicator();
                      }
                      final staff = snapshot.data!;
                      return DropdownButtonFormField<int?>(
                        initialValue: staffId,
                        decoration: InputDecoration(
                          labelText: context.text.staff,
                        ),
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text(context.text.anySpecialist),
                          ),
                          if (staffId != null &&
                              !staff.any((person) => person.id == staffId))
                            DropdownMenuItem<int?>(
                              value: staffId,
                              child: Text('${context.text.staff} $staffId'),
                            ),
                          for (final person in staff)
                            DropdownMenuItem<int?>(
                              value: person.id,
                              child: Text(person.name),
                            ),
                        ],
                        onChanged: (value) =>
                            setSheetState(() => staffId = value),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    initialValue: duration,
                    decoration: InputDecoration(
                      labelText: context.text.maxDuration,
                    ),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text(context.text.anyDuration),
                      ),
                      for (final minutes in [30, 60, 90, 120])
                        DropdownMenuItem<int?>(
                          value: minutes,
                          child: Text('$minutes ${context.text.duration}'),
                        ),
                    ],
                    onChanged: (value) => setSheetState(() => duration = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: sort == 'price' ? order : null,
                    decoration: InputDecoration(labelText: context.text.sortBy),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(context.text.defaultSort),
                      ),
                      DropdownMenuItem(
                        value: 'asc',
                        child: Text(context.text.priceLowToHigh),
                      ),
                      DropdownMenuItem(
                        value: 'desc',
                        child: Text(context.text.priceHighToLow),
                      ),
                    ],
                    onChanged: (value) => setSheetState(() {
                      sort = value == null ? null : 'price';
                      order = value;
                    }),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: context.text.confirm,
                    onPressed: () {
                      cubit.load(
                        query: ServiceQuery(
                          categoryId: query.categoryId,
                          q: _search.text,
                          staffId: staffId,
                          maxDuration: duration,
                          sort: sort,
                          order: order,
                        ),
                      );
                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      scrolledUnderElevation: 0,
      title: BlocBuilder<ServicesCubit, ServicesState>(
        builder: (context, state) => Text(
          state.query.categoryId == null
              ? context.text.services
              : widget.categoryName ?? context.text.services,
        ),
      ),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: context.text.searchServices,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      tooltip: context.text.search,
                      onPressed: _submit,
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              BlocBuilder<ServicesCubit, ServicesState>(
                builder: (context, state) {
                  final q = state.query;
                  final active =
                      q.staffId != null ||
                      q.maxDuration != null ||
                      q.sort != null;
                  return _FilterButton(
                    tooltip: context.text.filters,
                    active: active,
                    onPressed: _filters,
                  );
                },
              ),
            ],
          ),
        ),
        BlocBuilder<ServicesCubit, ServicesState>(
          builder: (context, state) {
            final q = state.query;
            if (q.categoryId == null &&
                q.staffId == null &&
                q.maxDuration == null &&
                q.sort == null &&
                (q.q == null || q.q!.isEmpty)) {
              return const SizedBox.shrink();
            }
            return Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 20, bottom: 4),
                child: TextButton.icon(
                  onPressed: () {
                    _search.clear();
                    context.read<ServicesCubit>().load(
                      query: const ServiceQuery(),
                    );
                  },
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: Text(context.text.clearFilters),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    backgroundColor: context.colors.primaryMuted,
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            );
          },
        ),
        BlocBuilder<ServicesCubit, ServicesState>(
          builder: (context, state) {
            if (state.failure == null || state.items.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                state.failure!.localized(context),
                style: context.textTheme.bodyMedium,
              ),
            );
          },
        ),
        Expanded(
          child: BlocBuilder<ServicesCubit, ServicesState>(
            builder: (context, state) {
              final cubit = context.read<ServicesCubit>();
              if (state.loading && state.items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.failure != null && state.items.isEmpty) {
                return AppErrorView(
                  message: state.failure!.localized(context),
                  onRetry: cubit.load,
                );
              }
              if (state.items.isEmpty) {
                return AppEmptyView(
                  icon: Icons.spa_outlined,
                  title: context.text.noServices,
                  subtitle: context.text.searchServices,
                );
              }
              return RefreshIndicator(
                onRefresh: cubit.load,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  itemCount:
                      state.items.length +
                      (state.meta?.hasNextPage == true ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == state.items.length) {
                      return AppButton(
                        label: context.text.loadMore,
                        loading: state.loadingMore,
                        variant: AppButtonVariant.secondary,
                        onPressed: cubit.loadMore,
                      );
                    }
                    final service = state.items[index];
                    return CatalogServiceTile(
                      service: service,
                      currency: widget.currency,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => ServiceDetailsScreen(
                            serviceId: service.id,
                            currency: widget.currency,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
