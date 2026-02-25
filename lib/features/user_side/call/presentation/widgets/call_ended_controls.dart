import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/color.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/widgets/top_snackbar.dart';
import '../bloc/favorite_cubit.dart';

class CallEndedControls extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onCallAgain;

  const CallEndedControls({
    super.key,
    required this.onCancel,
    required this.onCallAgain,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoriteCubit(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionButton(
              icon: Icons.cancel,
              color: AppColors.amber,
              label: "Cancel",
              onTap: onCancel,
            ),
            BlocConsumer<FavoriteCubit, FavoriteState>(
              listener: (context, state) {
                if (state.isFavorite) {
                  showTopSnackBar(context, "Added to favorites list");
                }
              },
              builder: (context, state) {
                return _buildActionButton(
                  icon: state.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: AppColors.red,
                  label: "Add Favorites",
                  onTap: () {
                    context.read<FavoriteCubit>().toggleFavorite();
                  },
                );
              },
            ),
            _buildActionButton(
              icon: Icons.call,
              color: AppColors.green,
              label: "Call again",
              onTap: onCallAgain,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: color, size: 32),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}
