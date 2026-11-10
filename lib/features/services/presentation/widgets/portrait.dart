part of '../screens/staff_screens.dart';

class _Portrait extends StatelessWidget {
  const _Portrait(this.person, {required this.size, this.ring = false});
  final StaffModel person;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final image = ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: person.avatar?.isNotEmpty == true
            ? Image.network(
                person.avatar!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _Initials(person),
              )
            : _Initials(person),
      ),
    );
    if (!ring) return image;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.primary, width: 1.5),
      ),
      child: image,
    );
  }
}
