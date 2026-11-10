part of '../screens/main_screen.dart';

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) => BlocBuilder<UserCubit, UserState>(
    builder: (context, state) {
      if (state.status == AuthStatus.authenticated) {
        return const ProfileScreen();
      }
      final colors = context.colors;
      return Scaffold(
        appBar: AppBar(
          title: Text(context.text.profile),
          scrolledUnderElevation: 0,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: colors.primaryMuted,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 44,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.login),
                        icon: const Icon(Icons.login_rounded, size: 20),
                        label: Text(context.text.login),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(200, 52),
                          shape: const StadiumBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(
                        width: 360,
                        child: ProfilePreferencesCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
