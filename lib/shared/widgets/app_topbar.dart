import 'package:manzoma/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manzoma/core/localization/cubit/locale_cubit.dart';
import 'package:manzoma/core/theme/cubit/theme_cubit.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;

  const AppTopBar({
    super.key,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final localeCubit = context.watch<LocaleCubit>();
    final themeCubit = context.watch<ThemeCubit>();
    final isRtl = localeCubit.state.locale.languageCode == "ar";

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title (expanded عشان ياخد المتبقي)
            if (title != null)
              Expanded(
                child: Text(
                  title!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ),
              ),

            const SizedBox(width: 16),

            // Search Bar
            Expanded(
              flex: 2,
              child: _buildSearchBar(context, isRtl),
            ),

            const SizedBox(width: 16),

            // Actions Row
            Row(
              children: [
                _buildThemeButton(themeCubit),
                _buildLangButton(localeCubit),
                _buildNotifications(),
                _buildUserMenu(context),
                if (actions != null) ...actions!,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool rtl) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        decoration: InputDecoration(
          hintText: AppLocalizations.off(context).search,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildThemeButton(ThemeCubit themeCubit) {
    return IconButton(
      icon: Icon(
        themeCubit.state.themeData.brightness == Brightness.dark
            ? Icons.dark_mode
            : Icons.light_mode,
        color: Colors.grey.shade700,
      ),
      onPressed: () => themeCubit.toggleTheme(),
    );
  }

  Widget _buildLangButton(LocaleCubit localeCubit) {
    return IconButton(
      icon: const Icon(Icons.language, color: Colors.blueAccent),
      onPressed: () {
        if (localeCubit.state.locale.languageCode == "en") {
          localeCubit.changeLanguage("ar");
          print(localeCubit.state.locale.languageCode);
        } else {
          localeCubit.changeLanguage("en");
          print(localeCubit.state.locale.languageCode);
        }
      },
    );
  }

  Widget _buildNotifications() {
    return IconButton(
      icon: Stack(
        children: [
          const Icon(Icons.notifications_outlined, size: 24),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
              child: const Text(
                '3',
                style: TextStyle(color: Colors.white, fontSize: 8),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {},
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
        ],
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person_outline),
              const SizedBox(width: 12),
              Text(AppLocalizations.off(context).profile),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings_outlined),
              const SizedBox(width: 12),
              Text(AppLocalizations.off(context).settings),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, color: Colors.red),
              const SizedBox(width: 12),
              Text(AppLocalizations.off(context).logout,
                  style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'profile':
            context.go('/settings/profile');
            break;
          case 'settings':
            context.go('/settings');
            break;
          case 'logout':
            context.go('/login');
            break;
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
