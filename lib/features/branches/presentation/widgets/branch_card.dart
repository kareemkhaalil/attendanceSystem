import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/branch_entity.dart';

class BranchCard extends StatelessWidget {
  final BranchEntity branch;
  final VoidCallback? onTap;
  final Widget? trailing; // <--- إضافة هذا السطر

  const BranchCard({
    super.key,
    required this.branch,
    this.onTap,
    this.trailing, // <--- إضافة هذا السطر
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Branch Icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.store,
                  size: 24.w,
                  color: const Color(0xFF2563EB),
                ),
              ),
              SizedBox(width: 16.w),
              // Branch Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.displayName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    if (branch.address != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14.w,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              branch.address!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.gps_fixed,
                          size: 14.w,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${branch.latitude.toStringAsFixed(4)}, ${branch.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Icon(
                          Icons.radio_button_checked,
                          size: 14.w,
                          color: Colors.green,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${branch.radiusMeters.toStringAsFixed(0)}م',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16.w,
                color: Colors.grey[400],
              ),
              if (trailing != null)
                trailing!
              else
                Icon(
                  // fallback
                  Icons.arrow_forward_ios,
                  size: 16.w,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
