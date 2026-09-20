import 'package:dio/dio.dart';
import '../const.dart';
import '../models/todo_item.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.isNetwork = false});
  final String message;
  final bool isNetwork;
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 120),
    headers: {'Content-Type': 'application/json'},
  ));

  Future<void> checkConnection() async {
    try {
      await _dio.get('/api/health');
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        throw ApiException('暂时连接不上星助校园', isNetwork: true);
      }
    } catch (_) {}
  }

  bool _isNetworkError(DioException e) =>
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout;

  String _friendlyError(DioException e) {
    if (_isNetworkError(e)) return '暂时连接不上星助校园，请检查网络';
    return '操作失败，请稍后重试';
  }

  Future<T> _wrap<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      throw ApiException(_friendlyError(e), isNetwork: _isNetworkError(e));
    }
  }

  Future<Map<String, dynamic>> noteGenerate({
    required String content,
    String? pdfBase64,
  }) =>
      _wrap(() async {
        final data = <String, dynamic>{'content': content};
        if (pdfBase64 != null && pdfBase64.isNotEmpty) {
          data['pdf_base64'] = pdfBase64;
        }
        final res = await _dio.post('/api/study/note_generate', data: data);
        return res.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> reviewPlan({
    required String subject,
    required int remainDays,
    required String weakPoints,
  }) =>
      _wrap(() async {
        final res = await _dio.post('/api/study/review_plan', data: {
          'subject': subject,
          'remain_days': remainDays,
          'weak_points': weakPoints,
        });
        return res.data as Map<String, dynamic>;
      });

  Future<String> exportTxt({
    required String content,
    required String filename,
  }) =>
      _wrap(() async {
        final res = await _dio.post('/api/export/txt', data: {
          'content': content,
          'filename': filename,
        });
        return res.data['download_url']?.toString() ?? '';
      });

  Future<List<dynamic>> contestCardList() => _wrap(() async {
        final res = await _dio.get('/api/contest/card_list');
        final data = res.data;
        if (data is List) return data;
        if (data is Map && data['items'] is List) return data['items'] as List;
        return [];
      });

  Future<Map<String, dynamic>> createContestCard({
    required String contestName,
    required String skills,
    required String availableTime,
    required String teammateExpect,
    String? contact,
  }) =>
      _wrap(() async {
        final res = await _dio.post('/api/contest/create_card', data: {
          'contest_name': contestName,
          'skills': skills,
          'available_time': availableTime,
          'teammate_expect': teammateExpect,
          if (contact != null && contact.isNotEmpty) 'contact': contact,
        });
        return res.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> matchAnalysis({
    required String cardAId,
    required String cardBId,
  }) =>
      _wrap(() async {
        final res = await _dio.post('/api/contest/match_analysis', data: {
          'card_a_id': cardAId,
          'card_b_id': cardBId,
        });
        return res.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> resumePolish({
    required String resumeRawText,
  }) =>
      _wrap(() async {
        final res = await _dio.post('/api/document/resume_polish', data: {
          'resume_raw_text': resumeRawText,
        });
        return res.data as Map<String, dynamic>;
      });

  Future<String> resumePdf({required String resumeRawText}) => _wrap(() async {
        final res = await _dio.post('/api/document/resume_pdf', data: {
          'resume_raw_text': resumeRawText,
        });
        return res.data['download_url']?.toString() ?? '';
      });

  Future<Map<String, dynamic>> planGenerate({
    required String activityName,
    required String activityDesc,
    required String venue,
    required String budget,
    required String targetAudience,
  }) =>
      _wrap(() async {
        final res = await _dio.post('/api/document/plan_generate', data: {
          'activity_name': activityName,
          'activity_desc': activityDesc,
          'venue': venue,
          'budget': budget,
          'target_audience': targetAudience,
        });
        return res.data as Map<String, dynamic>;
      });

  Future<List<String>> todoMonthDates({required int year, required int month}) =>
      _wrap(() async {
        final res = await _dio.get('/api/todo/month', queryParameters: {
          'year': year,
          'month': month,
        });
        final dates = res.data['dates'];
        if (dates is List) return dates.map((e) => '$e').toList();
        return [];
      });

  Future<List<TodoItem>> todoListByDate(String date) => _wrap(() async {
        final res = await _dio.get('/api/todo/list', queryParameters: {'date': date});
        final items = res.data['items'];
        if (items is List) {
          return items
              .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      });

  Future<TodoItem> createTodo({
    required String title,
    required String date,
    String dueTime = '',
    String note = '',
    String category = 'study',
  }) =>
      _wrap(() async {
        final res = await _dio.post('/api/todo/create', data: {
          'title': title,
          'date': date,
          'due_time': dueTime,
          'note': note,
          'category': category,
        });
        return TodoItem.fromJson(res.data as Map<String, dynamic>);
      });

  Future<TodoItem> toggleTodo(String id, bool completed) => _wrap(() async {
        final res = await _dio.patch('/api/todo/$id', data: {'completed': completed});
        return TodoItem.fromJson(res.data as Map<String, dynamic>);
      });

  Future<void> deleteTodo(String id) => _wrap(() async {
        await _dio.delete('/api/todo/$id');
      });

  static String extractText(Map<String, dynamic> res, [String key = 'result']) {
    return res[key]?.toString() ??
        res['data']?.toString() ??
        res['note_text']?.toString() ??
        res['plan_text']?.toString() ??
        res['polished_text']?.toString() ??
        '';
  }
}
