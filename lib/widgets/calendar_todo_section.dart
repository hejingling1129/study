import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/todo_item.dart';
import '../services/api_service.dart';
import '../utils/toast_util.dart';

class CalendarTodoSection extends StatefulWidget {
  const CalendarTodoSection({super.key});

  @override
  State<CalendarTodoSection> createState() => _CalendarTodoSectionState();
}

class _CalendarTodoSectionState extends State<CalendarTodoSection> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;
  Set<String> _markedDates = {};
  List<TodoItem> _todos = [];
  bool _loadingTodos = false;

  static const _weekLabels = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _loadMonth();
    _loadTodos();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _loadMonth() async {
    try {
      final dates = await ApiService.instance.todoMonthDates(
        year: _focusedMonth.year,
        month: _focusedMonth.month,
      );
      if (mounted) setState(() => _markedDates = dates.toSet());
    } on ApiException {
      // ignore
    }
  }

  Future<void> _loadTodos() async {
    setState(() => _loadingTodos = true);
    try {
      final list = await ApiService.instance.todoListByDate(_fmt(_selectedDate));
      if (mounted) setState(() => _todos = list);
    } on ApiException {
      showErrorToast();
    } finally {
      if (mounted) setState(() => _loadingTodos = false);
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
    _loadMonth();
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = date);
    _loadTodos();
  }

  Future<void> _toggleTodo(TodoItem item) async {
    try {
      final updated = await ApiService.instance.toggleTodo(item.id, !item.completed);
      setState(() {
        _todos = _todos.map((t) => t.id == item.id ? updated : t).toList();
      });
    } on ApiException {
      showErrorToast();
    }
  }

  Future<void> _showAddDialog() async {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '18:00');
    final noteCtrl = TextEditingController();
    var category = 'study';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('添加待办 · ${_fmt(_selectedDate)}'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: '标题',
                      hintText: '例如：完成复习计划',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: timeCtrl,
                    decoration: const InputDecoration(
                      labelText: '截止时间',
                      hintText: '18:00',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      hintText: '简单说明…',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: '类型'),
                    items: const [
                      DropdownMenuItem(value: 'study', child: Text('学习复习')),
                      DropdownMenuItem(value: 'contest', child: Text('竞赛截止')),
                      DropdownMenuItem(value: 'document', child: Text('文书任务')),
                    ],
                    onChanged: (v) => setDialog(() => category = v ?? 'study'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            FilledButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) {
                  showErrorToast('请填写标题');
                  return;
                }
                Navigator.pop(ctx);
                try {
                  await ApiService.instance.createTodo(
                    title: titleCtrl.text.trim(),
                    date: _fmt(_selectedDate),
                    dueTime: timeCtrl.text.trim(),
                    note: noteCtrl.text.trim(),
                    category: category,
                  );
                  showSuccessToast('待办已添加');
                  await _loadMonth();
                  await _loadTodos();
                } on ApiException {
                  showErrorToast();
                }
              },
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );

    titleCtrl.dispose();
    timeCtrl.dispose();
    noteCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: const [AppTheme.cardShadow],
      ),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📆 日历与待办事项',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '${_focusedMonth.year}年${_focusedMonth.month}月',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _monthNavButton(Icons.chevron_left, () => _changeMonth(-1)),
              const SizedBox(width: 8),
              _monthNavButton(Icons.chevron_right, () => _changeMonth(1)),
            ],
          ),
          const SizedBox(height: 10),
          _buildWeekHeader(),
          const SizedBox(height: 4),
          _buildCalendarGrid(),
          const SizedBox(height: 18),
          const Divider(color: Color(0xfff0eef8), height: 1),
          const SizedBox(height: 14),
          _buildTodoList(),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppTheme.btnGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x595b58d8),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showAddDialog,
                  borderRadius: BorderRadius.circular(14),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    child: Text(
                      '+  新增待办',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthNavButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppTheme.mintSoft,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 26,
          height: 26,
          child: Icon(icon, size: 16, color: AppTheme.primary),
        ),
      ),
    );
  }

  Widget _buildWeekHeader() {
    return Row(
      children: _weekLabels
          .map(
            (w) => Expanded(
              child: Center(
                child: Text(
                  w,
                  style: const TextStyle(
                    color: Color(0xffa8a4d4),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startWeekday = first.weekday;
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 4,
        childAspectRatio: 1.15,
      ),
      itemCount: 42,
      itemBuilder: (_, index) {
        final dayNum = index - startWeekday + 1;
        if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox.shrink();

        final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
        final key = _fmt(date);
        final isSelected = _selectedDate.year == date.year &&
            _selectedDate.month == date.month &&
            _selectedDate.day == date.day;
        final isToday = today.year == date.year &&
            today.month == date.month &&
            today.day == date.day;
        final hasTodo = _markedDates.contains(key);

        return GestureDetector(
          onTap: () => _selectDate(date),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.btnGradient : null,
                  color: isSelected ? null : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday && !isSelected
                      ? Border.all(color: AppTheme.primary, width: 1.4)
                      : null,
                ),
                child: Text(
                  '$dayNum',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xff3d3a6b),
                  ),
                ),
              ),
              if (hasTodo)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodoList() {
    if (_loadingTodos) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
          ),
        ),
      );
    }

    if (_todos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          '这一天还没有待办，点「新增待办」记录复习、竞赛或文书任务',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      );
    }

    return Column(
      children: _todos.map(_todoTile).toList(),
    );
  }

  Widget _todoTile(TodoItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _toggleTodo(item),
            child: Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                gradient: item.completed ? AppTheme.btnGradient : null,
                borderRadius: BorderRadius.circular(7),
                border: item.completed
                    ? null
                    : Border.all(color: const Color(0xffc4c1e8), width: 2),
              ),
              child: item.completed
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: item.completed
                        ? AppTheme.textTertiary
                        : const Color(0xff2d2a6e),
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    decoration:
                        item.completed ? TextDecoration.lineThrough : null,
                    decorationColor: AppTheme.textTertiary,
                  ),
                ),
                if (item.dueTime.isNotEmpty || item.note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      [
                        if (item.dueTime.isNotEmpty) '截止：${item.dueTime}',
                        if (item.note.isNotEmpty) item.note,
                      ].join(' · '),
                      style: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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
