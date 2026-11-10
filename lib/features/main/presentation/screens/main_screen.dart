import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/config/routes/routes.dart';
import 'package:booking_app/core/di/injection_container.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_cubit.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_state.dart';
import 'package:booking_app/features/auth/presentation/screens/profile_screen.dart';
import 'package:booking_app/features/booking/presentation/bookings_screen.dart';
import 'package:booking_app/features/direct/presentation/screens/direct_screen.dart';
import 'package:booking_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:booking_app/features/home/presentation/screens/home_screen.dart';
import 'package:booking_app/features/services/presentation/screens/services_screen.dart';
import 'package:booking_app/features/settings/presentation/widgets/profile_preferences_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '../widgets/floating_nav_bar.dart';
part '../widgets/nav_button.dart';
part '../widgets/profile_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final _visited = <int>{0};

  void _select(int index) {
    if (index == _selectedIndex) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
      _visited.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final items = <_NavItemData>[
      _NavItemData(Icons.home_outlined, Icons.home_rounded, text.home),
      _NavItemData(Icons.spa_outlined, Icons.spa_rounded, text.services),
      _NavItemData(
        Icons.event_note_outlined,
        Icons.event_note_rounded,
        text.myBookings,
      ),
      _NavItemData(Icons.bolt_outlined, Icons.bolt_rounded, text.direct),
      _NavItemData(
        Icons.person_outline_rounded,
        Icons.person_rounded,
        text.profile,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          BlocProvider(
            create: (_) => sl<HomeCubit>()..fetchHome(),
            child: const HomeScreen(),
          ),
          _visited.contains(1)
              ? const ServicesScreen()
              : const SizedBox.shrink(),
          _visited.contains(2)
              ? const BookingsScreen()
              : const SizedBox.shrink(),
          _visited.contains(3) ? const DirectScreen() : const SizedBox.shrink(),
          _visited.contains(4) ? const _ProfileTab() : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: _FloatingNavBar(
        items: items,
        selectedIndex: _selectedIndex,
        onSelected: _select,
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
