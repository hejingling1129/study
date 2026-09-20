import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/todo_item.dart';
import '../services/api_service.dart';
import '../widgets/calendar_todo_section.dart';
import '../widgets/constrained_content.dart';
import '../widgets/hero_diffused_background.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onNavigateToTab});

  final ValueChanged<int> onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppTheme.desktopBreakpoint;
    final hPad = width >= AppTheme.tabletBreakpoint ? 24.0 : 20.0;
    return ColoredBox(
      color: AppTheme.pageBg,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return HeroDiffusedBackground(
                          height: constraints.maxHeight,
                        );
                      },
                    ),
                  ),
                  ConstrainedContent(
                    padding: EdgeInsets.fromLTRB(
                      hPad,
                      isDesktop ? 16 : 8,
                      hPad,
                      8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 20),
                        _buildGreeting(),
                        const SizedBox(height: 28),
                        _buildShortcutStrip(isDesktop),
                        const SizedBox(height: 16),
                        const _TodayProgressBanner(),
                      ],
                    ),
                  ),
                ],
              ),
              ConstrainedContent(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 28),
                child: const CalendarTodoSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _glassIconButton(Icons.menu_rounded),
        const Spacer(),
        Stack(
          children: [
            _glassIconButton(Icons.notifications_none_rounded),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0x805b58d8),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _glassIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  Widget _buildGreeting() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '你好，用户！',
          style: TextStyle(
            color: Color(0xbfffffff),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '今天也要高效完成',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        Text(
          '校园任务 ✨',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutStrip(bool isDesktop) {
    final entries = [
      (
        Icons.menu_book_rounded,
        '学习中心',
        'AI整理笔记、智能生成复习计划',
        const Color(0xffeeecff),
        const Color(0xff5b58d8),
        1,
      ),
      (
        Icons.description_rounded,
        '文书中心',
        '简历编辑、AI润色、活动策划一键写',
        const Color(0xfff3eeff),
        const Color(0xff8b5cf6),
        3,
      ),
      (
        Icons.emoji_events_rounded,
        '竞赛广场',
        '寻找竞赛搭子、智能匹配队友',
        const Color(0xfffaf0ff),
        const Color(0xffc084fc),
        2,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < entries.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AppTheme.divider,
                  ),
                ),
              Expanded(
                child: InkWell(
                  onTap: () => onNavigateToTab(entries[i].$6),
                  borderRadius: BorderRadius.circular(22),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 16 : 10,
                      vertical: 14,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: entries[i].$4,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            entries[i].$1,
                            color: entries[i].$5,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          entries[i].$2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entries[i].$3,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TodayProgressBanner extends StatefulWidget {
  const _TodayProgressBanner();

  @override
  State<_TodayProgressBanner> createState() => _TodayProgressBannerState();
}

class _TodayProgressBannerState extends State<_TodayProgressBanner> {
  List<TodoItem> _todos = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    try {
      final list = await ApiService.instance.todoListByDate(date);
      if (mounted) setState(() => _todos = list);
    } on ApiException {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _todos.isEmpty ? 4 : _todos.length;
    final done = _todos.isEmpty ? 2 : _todos.where((t) => t.completed).length;
    final remaining = _todos.where((t) => !t.completed).toList();
    final hint = remaining.isEmpty
        ? (_todos.isEmpty ? '剩余任务：生成一份复习计划' : '今日待办已全部完成')
        : '剩余任务：${remaining.first.title}';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.brandDark, AppTheme.primary],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x593b38c2),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🌟', style: TextStyle(fontSize: 26)),
                Text(
                  '星小助',
                  style: TextStyle(
                    color: Color(0xb3ffffff),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '今日任务进度',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < 4; i++)
                      Expanded(
                        child: Container(
                          height: 8,
                          margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
                          decoration: BoxDecoration(
                            color: i < (done * 4 / total).ceil().clamp(0, 4)
                                ? Colors.white.withValues(alpha: 0.9)
                                : Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      '$done/$total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
