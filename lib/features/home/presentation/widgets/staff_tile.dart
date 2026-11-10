import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/features/home/data/models/staff_model.dart';
import 'package:booking_app/features/home/presentation/widgets/remote_image.dart';
import 'package:booking_app/features/services/presentation/screens/staff_screens.dart';
import 'package:flutter/material.dart';

class StaffTile extends StatelessWidget {
  const StaffTile({super.key, required this.staff});
  final StaffModel staff;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 112,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => StaffDetailsScreen(staffId: staff.id),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.primary, width: 1.5),
              ),
              child: ClipOval(
                child: SizedBox.square(
                  dimension: 78,
                  child: staff.avatar?.isNotEmpty == true
                      ? RemoteImage(
                          url: staff.avatar,
                          icon: Icons.person_outline,
                        )
                      : ColoredBox(
                          color: colors.primaryMuted,
                          child: Center(
                            child: Text(
                              staff.initials ?? staff.name.characters.first,
                              style: context.textTheme.headlineMedium?.copyWith(
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              staff.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textTheme.titleSmall,
            ),
            if (staff.title?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  staff.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
