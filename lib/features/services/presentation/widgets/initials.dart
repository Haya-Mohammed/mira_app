part of '../screens/staff_screens.dart';

class _Initials extends StatelessWidget {
  const _Initials(this.person);
  final StaffModel person;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.primaryMuted,
    child: Center(
      child: Text(
        person.initials ?? person.name.characters.first,
        style: context.textTheme.headlineMedium?.copyWith(
          color: context.colors.primary,
        ),
      ),
    ),
  );
}
