import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/toast_util.dart';
import '../widgets/constrained_content.dart';
import '../widgets/contest_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_button.dart';

class ContestPage extends StatefulWidget {
  const ContestPage({super.key});

  @override
  State<ContestPage> createState() => _ContestPageState();
}

class _ContestPageState extends State<ContestPage> {
  static const _filters = ['全部', 'AI', '编程', '设计', '商业', '科研', '其他'];

  List<ContestCardData> _cards = [];
  final Set<String> _selectedIds = {};
  String _activeFilter = '全部';
  bool _matchLoading = false;
  bool _listLoading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  List<ContestCardData> get _filteredCards {
    if (_activeFilter == '全部') return _cards;
    return _cards.where((c) {
      final cat = c.category ?? '';
      final tags = c.skillTags.join(' ');
      return cat.contains(_activeFilter) || tags.contains(_activeFilter);
    }).toList();
  }

  Future<void> _loadCards() async {
    setState(() => _listLoading = true);
    try {
      final list = await ApiService.instance.contestCardList();
      setState(() {
        _cards = list
            .map((e) => ContestCardData.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } on ApiException {
      showErrorToast();
    } finally {
      if (mounted) setState(() => _listLoading = false);
    }
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else if (_selectedIds.length < 2) {
        _selectedIds.add(id);
      } else {
        showErrorToast('最多选择两张卡片进行匹配');
      }
    });
  }

  Future<void> _showCreateDialog() async {
    final nameCtrl = TextEditingController();
    final skillsCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final expectCtrl = TextEditingController();
    final contactCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '发布竞赛招募',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: '竞赛名称',
                      hintText: '例如：互联网+大学生创新创业大赛',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: skillsCtrl,
                    decoration: const InputDecoration(
                      labelText: '个人擅长技能',
                      hintText: '例如：Python、产品设计、商业分析',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: timeCtrl,
                    decoration: const InputDecoration(
                      labelText: '每周可投入时间',
                      hintText: '例如：每周 10 小时',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: expectCtrl,
                    decoration: const InputDecoration(
                      labelText: '期望队友特质',
                      hintText: '例如：责任心强、有执行力',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contactCtrl,
                    decoration: const InputDecoration(
                      labelText: '联系方式',
                      hintText: '选填，仅用于线下联系',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          if (nameCtrl.text.trim().isEmpty) {
                            showErrorToast('请填写竞赛名称');
                            return;
                          }
                          Navigator.pop(ctx);
                          setState(() => _submitting = true);
                          try {
                            await ApiService.instance.createContestCard(
                              contestName: nameCtrl.text.trim(),
                              skills: skillsCtrl.text.trim(),
                              availableTime: timeCtrl.text.trim(),
                              teammateExpect: expectCtrl.text.trim(),
                              contact: contactCtrl.text.trim(),
                            );
                            showSuccessToast('发布成功');
                            await _loadCards();
                          } on ApiException {
                            showErrorToast();
                          } finally {
                            if (mounted) setState(() => _submitting = false);
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                        ),
                        child: const Text('发布招募'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    nameCtrl.dispose();
    skillsCtrl.dispose();
    timeCtrl.dispose();
    expectCtrl.dispose();
    contactCtrl.dispose();
  }

  void _showDetail(ContestCardData data) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.contestName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                _detailRow('擅长技能', data.skills),
                _detailRow('可用时间', data.availableTime),
                _detailRow('队友要求', data.teammateExpect),
                if (data.contact != null && data.contact!.isNotEmpty)
                  _detailRow('联系方式', data.contact!),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('关闭'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppTheme.textSecondary, height: 1.5)),
        ],
      ),
    );
  }

  Future<void> _matchAnalysis() async {
    if (_selectedIds.length < 2) {
      showErrorToast('请先选择两张卡片');
      return;
    }
    final ids = _selectedIds.toList();
    setState(() => _matchLoading = true);
    try {
      final res = await ApiService.instance.matchAnalysis(
        cardAId: ids[0],
        cardBId: ids[1],
      );
      if (!mounted) return;
      _showMatchResult(res);
      showSuccessToast('匹配分析完成');
    } on ApiException {
      showErrorToast();
    } finally {
      if (mounted) setState(() => _matchLoading = false);
    }
  }

  void _onCardMatch(String cardId) {
    if (!_selectedIds.contains(cardId)) {
      _toggleSelect(cardId);
    }
    if (_selectedIds.length == 2) {
      _matchAnalysis();
    } else {
      showErrorToast('请再选择一张卡片进行匹配');
    }
  }

  void _showMatchResult(Map<String, dynamic> res) {
    final score = res['score'] ?? res['match_score'] ?? 0;
    final advantages = res['advantages']?.toString() ??
        res['match_advantages']?.toString() ??
        '';
    final risks = res['risks']?.toString() ?? res['match_risks']?.toString() ?? '';
    final suggestions = res['suggestions']?.toString() ??
        res['match_suggestions']?.toString() ??
        '';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI 组队适配分析',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '$score',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        const Text(
                          '匹配度',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _matchSection('双方适配优势', advantages),
                  _matchSection('合作风险点', risks),
                  _matchSection('组队适配建议', suggestions),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('关闭'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _matchSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.isNotEmpty ? content : '暂无数据',
            style: const TextStyle(height: 1.6, color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final hPad = width >= AppTheme.tabletBreakpoint ? 24.0 : 16.0;
    final crossCount = width >= AppTheme.desktopBreakpoint
        ? 3
        : width >= AppTheme.tabletBreakpoint
            ? 2
            : 1;
    final cards = _filteredCards;

    return Stack(
      children: [
        SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ConstrainedContent(
                  padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
                  child: PageHeader(
                    title: '🏆 竞赛搭子广场',
                    subtitle: '找到兴趣相投、能力互补的队友',
                    trailing: LoadingButton(
                      text: '＋ 发布招募',
                      loadingText: '发布中...',
                      isLoading: _submitting,
                      height: 40,
                      onPressed: _showCreateDialog,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final f = _filters[i];
                        final selected = _activeFilter == f;
                        return FilterChip(
                          label: Text(f),
                          selected: selected,
                          onSelected: (_) => setState(() => _activeFilter = f),
                          backgroundColor: Colors.white,
                          selectedColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                          side: BorderSide(
                            color: selected ? AppTheme.primary : AppTheme.divider,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusTag),
                          ),
                          showCheckmark: false,
                        );
                      },
                    ),
                  ),
                ),
              ),
              if (_selectedIds.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.mintSoft,
                        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '已选 ${_selectedIds.length}/2 张卡片',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => setState(_selectedIds.clear),
                            child: const Text('清除'),
                          ),
                          LoadingButton(
                            text: 'AI匹配分析',
                            loadingText: '分析中...',
                            height: 36,
                            isLoading: _matchLoading,
                            onPressed: _matchAnalysis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_listLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (cards.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    title: '还没有招募信息',
                    description: '成为第一个发布竞赛招募的人吧。',
                    actionText: '发布招募',
                    onAction: _showCreateDialog,
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.all(hPad),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 340,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final card = cards[index];
                        return ContestCard(
                          data: card,
                          isSelected: _selectedIds.contains(card.id),
                          onSelect: () => _toggleSelect(card.id),
                          onViewDetail: () => _showDetail(card),
                          onMatch: () => _onCardMatch(card.id),
                        );
                      },
                      childCount: cards.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_matchLoading) _matchOverlay(),
      ],
    );
  }

  Widget _matchOverlay() {
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(28),
        decoration: AppTheme.cardDecoration(radius: AppTheme.radiusLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AI 正在分析双方信息...',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.mintSoft,
                borderRadius: BorderRadius.circular(AppTheme.radiusBtn),
              ),
              child: const Text('[星小助]', style: TextStyle(color: AppTheme.primary)),
            ),
            const SizedBox(height: 12),
            const Text(
              '正在比较技能、时间与队友诉求',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
