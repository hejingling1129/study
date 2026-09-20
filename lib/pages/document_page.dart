import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/download_util.dart';
import '../utils/toast_util.dart';
import '../widgets/app_dialog.dart';
import '../widgets/constrained_content.dart';
import '../widgets/loading_button.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({super.key});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _polishLoading = false;
  bool _pdfLoading = false;
  bool _planLoading = false;
  String _planResult = '';

  late QuillController _quillController;
  late FocusNode _focusNode;
  late ScrollController _scrollController;
  final _activityNameCtrl = TextEditingController();
  final _activityDescCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();

  static final _toolbarConfig = QuillSimpleToolbarConfig(
    showFontFamily: false,
    showFontSize: false,
    showColorButton: false,
    showBackgroundColorButton: false,
    showClearFormat: false,
    showCodeBlock: false,
    showQuote: false,
    showLink: false,
    showSearchButton: false,
    showSubscript: false,
    showSuperscript: false,
    showInlineCode: false,
    showStrikeThrough: false,
    showListCheck: false,
    showIndent: false,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _quillController = QuillController.basic();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _quillController.dispose();
    _activityNameCtrl.dispose();
    _activityDescCtrl.dispose();
    _venueCtrl.dispose();
    _budgetCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  String _getResumeText() => _quillController.document.toPlainText().trim();

  void _setResumeText(String text) {
    _quillController.document = Document()..insert(0, text);
  }

  Future<void> _confirmPolish() async {
    if (_getResumeText().isEmpty) {
      showErrorToast('请先输入简历内容');
      return;
    }
    await showAppDialog(
      context: context,
      title: 'AI 一键润色',
      content: const Text(
        'AI 将基于当前简历内容进行表达优化。\n\n不会改变你的核心经历信息。',
        style: TextStyle(height: 1.6, color: AppTheme.textSecondary),
      ),
      confirmText: '开始润色',
      onConfirm: _polishResume,
    );
  }

  Future<void> _polishResume() async {
    setState(() => _polishLoading = true);
    try {
      final res = await ApiService.instance.resumePolish(
        resumeRawText: _getResumeText(),
      );
      final polished = ApiService.extractText(res, 'polished_text');
      if (polished.isNotEmpty) {
        _setResumeText(polished);
        showSuccessToast('简历润色完成');
      } else {
        showErrorToast('未返回润色结果');
      }
    } on ApiException {
      showErrorToast();
    } finally {
      if (mounted) setState(() => _polishLoading = false);
    }
  }

  void _showPreview() {
    final text = _getResumeText();
    if (text.isEmpty) {
      showErrorToast('暂无内容可预览');
      return;
    }
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
                const Text(
                  '简历预览',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400,
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cardDecoration(),
                      child: Text(
                        text,
                        style: const TextStyle(height: 1.8, fontSize: 14),
                      ),
                    ),
                  ),
                ),
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

  Future<void> _exportPdf() async {
    final text = _getResumeText();
    if (text.isEmpty) {
      showErrorToast('暂无内容可导出');
      return;
    }
    setState(() => _pdfLoading = true);
    try {
      final url = await ApiService.instance.resumePdf(resumeRawText: text);
      if (url.isNotEmpty && await openDownloadUrl(url)) {
        showSuccessToast('PDF 导出成功');
      } else {
        showErrorToast('导出链接无效');
      }
    } on ApiException {
      showErrorToast();
    } finally {
      if (mounted) setState(() => _pdfLoading = false);
    }
  }

  Future<void> _generatePlan() async {
    if (_activityNameCtrl.text.trim().isEmpty) {
      showErrorToast('请填写活动名称');
      return;
    }
    setState(() => _planLoading = true);
    try {
      final res = await ApiService.instance.planGenerate(
        activityName: _activityNameCtrl.text.trim(),
        activityDesc: _activityDescCtrl.text.trim(),
        venue: _venueCtrl.text.trim(),
        budget: _budgetCtrl.text.trim(),
        targetAudience: _targetCtrl.text.trim(),
      );
      setState(() => _planResult = ApiService.extractText(res));
      showSuccessToast('策划书生成完成');
    } on ApiException {
      showErrorToast();
    } finally {
      if (mounted) setState(() => _planLoading = false);
    }
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    showSuccessToast('已复制到剪贴板');
  }

  Future<void> _exportPlanTxt() async {
    if (_planResult.isEmpty) return;
    try {
      final url = await ApiService.instance.exportTxt(
        content: _planResult,
        filename: 'plan.txt',
      );
      if (url.isNotEmpty && await openDownloadUrl(url)) {
        showSuccessToast('导出成功');
      } else {
        showErrorToast('导出链接无效');
      }
    } on ApiException {
      showErrorToast();
    }
  }

  double get _hPad {
    final w = MediaQuery.of(context).size.width;
    return w >= AppTheme.tabletBreakpoint ? 24 : 16;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(_hPad, 20, _hPad, 0),
            child: ConstrainedContent(
              child: const PageHeader(
                title: '文书中心',
                subtitle: '把校园文书写得更清楚、更专业',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(_hPad, 16, _hPad, 0),
            child: ConstrainedContent(
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.primary,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: AppTheme.divider,
                tabs: const [
                  Tab(text: '简历编辑器'),
                  Tab(text: '活动策划'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildResumeTab(),
                _buildPlanTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeTab() {
    final width = MediaQuery.of(context).size.width;
    final narrow = width < 600;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(_hPad),
          child: ConstrainedContent(
            child: Container(
              decoration: AppTheme.cardDecoration(radius: AppTheme.radiusLarge),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (narrow)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '我的简历',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        _actionButtons(),
                      ],
                    )
                  else
                    Row(
                      children: [
                        const Text(
                          '我的简历',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        _actionButtons(),
                      ],
                    ),
                  if (_polishLoading) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'AI 正在优化你的简历表达',
                      style: TextStyle(fontSize: 13, color: AppTheme.primary),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Column(
                      children: [
                        QuillSimpleToolbar(
                          controller: _quillController,
                          config: _toolbarConfig,
                        ),
                        const Divider(height: 1, color: AppTheme.divider),
                        SizedBox(
                          height: 360,
                          child: QuillEditor.basic(
                            controller: _quillController,
                            focusNode: _focusNode,
                            scrollController: _scrollController,
                            config: const QuillEditorConfig(
                              placeholder: '在此编辑你的简历内容...',
                              padding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          LoadingButton(
            text: 'AI一键润色',
            loadingText: '星小助正在润色...',
            isLoading: _polishLoading,
            height: 38,
            onPressed: _confirmPolish,
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: _showPreview,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.secondaryBtnBorder),
            ),
            child: const Text('实时预览'),
          ),
          const SizedBox(width: 8),
          LoadingButton(
            text: '导出PDF',
            loadingText: '导出中...',
            isLoading: _pdfLoading,
            height: 38,
            onPressed: _exportPdf,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_hPad),
      child: ConstrainedContent(
        child: Container(
          decoration: AppTheme.cardDecoration(radius: AppTheme.radiusLarge),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '活动策划',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                '输入活动基本信息，让星小助生成完整校园活动策划。',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _activityNameCtrl,
                decoration: const InputDecoration(
                  labelText: '活动名称',
                  hintText: '例如：校园音乐节',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _activityDescCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '活动简介',
                  hintText: '简单介绍活动目的和内容……',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _venueCtrl,
                decoration: const InputDecoration(
                  labelText: '举办场地',
                  hintText: '例如：学校大礼堂',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _budgetCtrl,
                decoration: const InputDecoration(
                  labelText: '预算范围',
                  hintText: '例如：5000～10000 元',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _targetCtrl,
                decoration: const InputDecoration(
                  labelText: '活动对象',
                  hintText: '例如：全校本科生',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  text: 'AI生成校园专属策划书',
                  loadingText: '星小助思考中...',
                  isLoading: _planLoading,
                  onPressed: _generatePlan,
                ),
              ),
              if (_planResult.isNotEmpty && !_planLoading) ...[
                const SizedBox(height: 24),
                Text(
                  _activityNameCtrl.text.isNotEmpty
                      ? '${_activityNameCtrl.text}活动策划书'
                      : '活动策划书',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.pageBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  ),
                  child: SelectableText(
                    _planResult,
                    style: const TextStyle(height: 1.7, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => _copyText(_planResult),
                      child: const Text('复制内容'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: _exportPlanTxt,
                      child: const Text('导出 TXT'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
