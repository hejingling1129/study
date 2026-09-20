import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'pages/contest_page.dart';
import 'pages/document_page.dart';
import 'pages/home_page.dart';
import 'pages/study_page.dart';
import 'services/api_service.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/network_error_view.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  bool _networkError = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkNetwork();
  }

  Future<void> _checkNetwork() async {
    setState(() {
      _checking = true;
      _networkError = false;
    });
    try {
      await ApiService.instance.checkConnection();
    } on ApiException catch (e) {
      if (e.isNetwork) _networkError = true;
    } catch (_) {}
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: AppTheme.pageBg,
        body: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_networkError) {
      return Scaffold(
        backgroundColor: AppTheme.pageBg,
        body: NetworkErrorView(onRetry: _checkNetwork),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AppTheme.desktopBreakpoint;
        final tabController = DefaultTabController.of(context);

        return Scaffold(
          backgroundColor: AppTheme.pageBg,
          body: Row(
            children: [
              if (isDesktop)
                AnimatedBuilder(
                  animation: tabController,
                  builder: (context, _) => AppSidebar(
                    currentIndex: tabController.index,
                    onTap: tabController.animateTo,
                  ),
                ),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    HomePage(
                      onNavigateToTab: tabController.animateTo,
                    ),
                    const StudyPage(),
                    const ContestPage(),
                    const DocumentPage(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isDesktop
              ? null
              : AnimatedBuilder(
                  animation: tabController,
                  builder: (context, _) => AppBottomNav(
                    currentIndex: tabController.index,
                    onTap: tabController.animateTo,
                  ),
                ),
        );
      },
    );
  }
}
