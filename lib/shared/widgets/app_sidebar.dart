import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzoma/core/localization/app_localizations.dart';
import 'package:manzoma/core/navigation/role_based_navigation.dart';
import 'package:manzoma/core/entities/user_entity.dart';
import '../../core/storage/shared_pref_helper.dart';
import 'package:manzoma/core/enums/user_role.dart';
import 'package:manzoma/core/localization/app_localizations_extra.dart';

class AppSidebar extends StatefulWidget {
  final bool isMobile;
  final VoidCallback? onItemTap;

  const AppSidebar({
    super.key,
    this.isMobile = false,
    this.onItemTap,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  String? expandedItem;
  String currentRoute = '/dashboard';
  UserEntity? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final user = SharedPrefHelper.getUser();
    setState(() {
      _currentUser = user;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentRoute = GoRouterState.of(context).uri.path;
  }

  @override
  Widget build(BuildContext context) {
    final currentRole = _currentUser?.role ?? UserRole.employee;
    final navigationItems =
        RoleBasedNavigation.getNavigationItemsForRole(currentRole);
    final localizations = AppLocalizations.off(context);

    return Directionality(
      textDirection: localizations.locale.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Container(
        width: widget.isMobile ? double.infinity : 280,
        decoration: BoxDecoration(
          boxShadow: widget.isMobile
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          children: [
            // 🔹 Logo/Header Section (أبيض)
            Container(
              height: widget.isMobile ? 60 : 80,
              padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/Asset 1.png',
                      width: widget.isMobile ? 100 : 160),
                  if (widget.isMobile)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
            ),

            // 🔹 باقي السايد بار (أزرق)
            Expanded(
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Column(
                  children: [
                    // Navigation Items
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                            vertical: widget.isMobile ? 4 : 8),
                        itemCount: navigationItems.length,
                        itemBuilder: (context, index) {
                          final item = navigationItems[index];
                          return _buildNavigationItem(item);
                        },
                      ),
                    ),

                    // User Info Section
                    Container(
                      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.3)),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: widget.isMobile ? 16 : 20,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                              size: widget.isMobile ? 16 : 20,
                            ),
                          ),
                          SizedBox(width: widget.isMobile ? 8 : 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentUser?.name ?? 'User',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: widget.isMobile ? 12 : 14,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _currentUser?.email ?? 'user@example.com',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: widget.isMobile ? 10 : 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: widget.isMobile ? 18 : 20,
                            ),
                            onPressed: () async {
                              await SharedPrefHelper.clearUser();
                              context.go('/login');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem(NavigationItem item) {
    final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;
    final isExpanded = expandedItem == item.titleKey;
    final loc = AppLocalizations.off(context);

    final isActive = currentRoute == item.route ||
        (item.subItems?.any((sub) => currentRoute == sub.route) ?? false);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (hasSubItems) {
                setState(() {
                  expandedItem = isExpanded ? null : item.titleKey;
                });
              } else {
                context.go(item.route);
                if (widget.isMobile && widget.onItemTap != null) {
                  widget.onItemTap!();
                }
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isMobile ? 12 : 16,
                vertical: widget.isMobile ? 8 : 12,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.15) // خلفية فاتحة عند التحديد
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: widget.isMobile ? 4 : 8,
                vertical: 2,
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: widget.isMobile ? 18 : 20,
                    color: isActive ? Colors.white : Colors.white70,
                  ),
                  SizedBox(width: widget.isMobile ? 8 : 12),
                  Expanded(
                    child: Text(
                      loc.translate(item.titleKey),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.normal,
                        fontSize: widget.isMobile ? 12 : 14,
                      ),
                    ),
                  ),
                  if (hasSubItems)
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: widget.isMobile ? 18 : 20,
                      color: Colors.white70,
                    ),
                ],
              ),
            ),
          ),
        ),

        // Sub Items
        if (hasSubItems && isExpanded)
          ...item.subItems!.map((subItem) => _buildSubNavigationItem(subItem)),
      ],
    );
  }

  Widget _buildSubNavigationItem(NavigationItem subItem) {
    final isActive = currentRoute == subItem.route;
    final loc = AppLocalizations.off(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.go(subItem.route);
          if (widget.isMobile && widget.onItemTap != null) {
            widget.onItemTap!();
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 12 : 16,
            vertical: widget.isMobile ? 6 : 8,
          ),
          margin: EdgeInsets.only(
            left: widget.isMobile ? 16 : 24,
            right: widget.isMobile ? 4 : 8,
            top: 2,
            bottom: 2,
          ),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withValues(alpha: 0.15) : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                subItem.icon,
                size: widget.isMobile ? 16 : 18,
                color: isActive ? Colors.white : Colors.white60,
              ),
              SizedBox(width: widget.isMobile ? 8 : 12),
              Expanded(
                child: Text(
                  loc.translate(subItem.titleKey),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: widget.isMobile ? 11 : 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
