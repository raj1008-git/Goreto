import 'package:flutter/material.dart';

import '../../../core/constants/appColors.dart';
import 'group_create_dialog.dart';

class CreateGroupFAB extends StatelessWidget {
  const CreateGroupFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreateGroupDialog(),
          );
        },
        backgroundColor: AppColors.secondary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        label: const Text(
          'Create Group',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
      ),
    );
  }
}
