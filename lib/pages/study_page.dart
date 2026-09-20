import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../services/api_service.dart';
import '../utils/download_util.dart';
import '../utils/toast_util.dart';
import '../widgets/constrained_content.dart';
import '../widgets/gradient_button.dart';
import '../widgets/loading_button.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  final _noteController = TextEditingController();
  final _subjectController = TextEditingController();
  final _daysController = TextEditingController();
  final _weakPointsController = TextEditingController();

  String? _pdfBase64;
  String? _pdfFileName;
  int? _pdfSize;
  String _noteResult = '';
  String _planResult = '';
  bool _noteLoading = false;
  bool _planLoading = false;
  bool _noteExpanded = false;
  bool _noteError = false;
  bool _planExpanded = false;

  @override
  void dispose() {
    _noteController.dispose();
    _subjectController.dispose();
    _daysController.dispose();
    _weakPointsController.dispose();
    super.dispose();
  }

  double get _hPad {
    final w = MediaQuery.of(context).size.width;
    return w >= AppTheme.tabletBreakpoint ? 24 : 16;
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      setState(() {
        _pdfBase64 = base64Encode(file.bytes!);
        _pdfFileName = file.name;
        _pdfSize = file.size;
      });
    }
  }

  void _removePdf() {
    setState(() {
      _pdfBase64 = null;
      _pdfFileName = null;
      _pdfSize = null;
    });
  }

  Future<void> _generateNote() async {
    if (_noteController.text.trim().isEmpty && _pdfBase64 == null) {
      showErrorToast('请输入笔记内容或上传 PDF');
      return;
    }
    setState(() {
      _noteLoading = true;
      _noteExpanded = true;
      _noteError = false;
    });
    try {
      final res = await ApiService.instance.noteGenerate(
        content: _noteController.text.trim(),
        pdfBase64: _pdfBase64,
      );
      setState(() => _noteResult = ApiService.extractText(res));
      showSuccessToast('笔记整理完成');
    } on ApiException {
      setState(() => _noteError = true);
      showErrorToast();
    } finally {
      setState(() => _noteLoading = false);
    }
  }

  Future<void> _generatePlan() async {
    if (_subjectController.text.trim().isEmpty) {
      showErrorToast('请输入科目名称');
      return;
    }
    final days = int.tryParse(_daysController.text.trim());
    if (days == null || days <= 0) {
      showErrorToast('请输入有效的备考天数');
      return;
    }
    setState(() => _planLoading = true);
    try {
      final res = await ApiService.instance.reviewPlan(
        subject: _subjectController.text.trim(),
        remainDays: days,
        weakPoints: _weakPointsController.text.trim(),
      );
      setState(() {
        _planResult = ApiService.extractText(res);
        _planExpanded = true;
      });
      showSuccessToast('复习计划生成完成');
    } on ApiException {
      showErrorToast();
    } finally {
      setState(() => _planLoading = false);
    }
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    showSuccessToast('已复制到剪贴板');
  }

  Future<void> _exportTxt(String content, String filename) async {
    if (content.isEmpty) return;
    try {
      final url = await ApiService.instance.exportTxt(
        content: content,
        filename: filename,
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

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppTheme.desktopBreakpoint;
    final isWide = width >= AppTheme.tabletBreakpoint;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(_hPad, 20, _hPad, 24),
        child: ConstrainedContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: '学习中心',
                subtitle: '让 AI 帮你把学习任务整理得更清楚',
              ),
              const SizedBox(height: 24),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _noteCard()),
                    const SizedBox(width: 20),
                    Expanded(child: _planCard()),
                  ],
                )
              else ...[
                _noteCard(),
                SizedBox(height: isWide ? 20 : 14),
                _planCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _noteCard() {
    return Container(
      decoration: AppTheme.cardDecoration(radius: AppTheme.radiusLarge),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '课程笔记智能整理',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '把零散课堂内容整理成真正能复习的知识结构',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Text(
            '课堂笔记',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: TextField(
              controller: _noteController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: '粘贴课堂笔记、老师重点或课堂记录……',
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SecondaryButton(
                text: '上传 PDF 课件',
                icon: Icons.add,
                onPressed: _pickPdf,
              ),
              const SizedBox(width: 12),
              const Text(
                '最多上传 1 个文件',
                style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
              ),
            ],
          ),
          if (_pdfFileName != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.inputFill,
                borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                border: Border.all(color: AppTheme.inputBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, size: 18, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _pdfFileName!,
                          style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_pdfSize != null)
                          Text(
                            _formatSize(_pdfSize!),
                            style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _removePdf,
                    icon: const Icon(Icons.close, size: 18),
                    color: AppTheme.textTertiary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: LoadingButton(
              text: '开始 AI 整理笔记',
              loadingText: '星小助思考中...',
              isLoading: _noteLoading,
              onPressed: _generateNote,
            ),
          ),
          if (_noteExpanded && !_noteLoading) ...[
            const SizedBox(height: 20),
            if (_noteError)
              _errorBox(onRetry: _generateNote)
            else if (_noteResult.isNotEmpty)
              _resultBox(
                title: 'AI 整理结果',
                content: _noteResult,
                onCopy: () => _copyText(_noteResult),
                onExport: () => _exportTxt(_noteResult, 'note.txt'),
              ),
          ],
        ],
      ),
    );
  }

  Widget _planCard() {
    return Container(
      decoration: AppTheme.cardDecoration(radius: AppTheme.radiusLarge),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '个性化复习计划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '告诉星小助你的考试时间和薄弱点，生成适合你的复习节奏。',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(
              labelText: '科目名称',
              hintText: '例如：高等数学',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _daysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '距离考试还有',
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 12, bottom: 14),
                child: Text('天', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _weakPointsController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '薄弱知识点',
              hintText: '例如：\n极限\n导数\n积分\n级数',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: LoadingButton(
              text: '生成专属复习计划',
              loadingText: '星小助思考中...',
              isLoading: _planLoading,
              onPressed: _generatePlan,
            ),
          ),
          if (_planExpanded && _planResult.isNotEmpty && !_planLoading) ...[
            const SizedBox(height: 20),
            _resultBox(
              title: '你的复习计划',
              content: _planResult,
              onCopy: () => _copyText(_planResult),
              onExport: () => _exportTxt(_planResult, 'plan.txt'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _errorBox({required VoidCallback onRetry}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        border: Border.all(color: AppTheme.accent),
      ),
      child: Column(
        children: [
          const Text(
            '这次没有整理成功',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            '可能是网络连接异常，请稍后再试。',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: onRetry, child: const Text('重新生成')),
        ],
      ),
    );
  }

  Widget _resultBox({
    required String title,
    required String content,
    required VoidCallback onCopy,
    required VoidCallback onExport,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() {
                if (title.contains('笔记')) _noteExpanded = false;
                if (title.contains('复习')) _planExpanded = false;
              }),
              child: const Text(
                '收起 ↑',
                style: TextStyle(fontSize: 13, color: AppTheme.primary),
              ),
            ),
          ],
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
            content,
            style: const TextStyle(height: 1.7, fontSize: 14, color: AppTheme.textPrimary),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton(onPressed: onCopy, child: const Text('复制内容')),
            const SizedBox(width: 10),
            OutlinedButton(onPressed: onExport, child: const Text('导出 TXT')),
          ],
        ),
      ],
    );
  }
}
