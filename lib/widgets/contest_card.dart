import 'package:flutter/material.dart';
import '../app_theme.dart';

class ContestCardData {
  ContestCardData({
    required this.id,
    required this.contestName,
    required this.skills,
    required this.skillTags,
    required this.availableTime,
    required this.teammateExpect,
    this.contact,
    this.category,
  });

  final String id;
  final String contestName;
  final String skills;
  final List<String> skillTags;
  final String availableTime;
  final String teammateExpect;
  final String? contact;
  final String? category;

  factory ContestCardData.fromJson(Map<String, dynamic> json) {
    final tags = json['skill_tags'];
    return ContestCardData(
      id: '${json['id'] ?? json['card_id'] ?? ''}',
      contestName: '${json['contest_name'] ?? ''}',
      skills: '${json['skills'] ?? ''}',
      skillTags: tags is List ? tags.map((e) => '$e').toList() : [],
      availableTime: '${json['available_time'] ?? ''}',
      teammateExpect: '${json['teammate_expect'] ?? ''}',
      contact: json['contact']?.toString(),
      category: json['category']?.toString(),
    );
  }
}

class ContestCard extends StatelessWidget {
  const ContestCard({
    super.key,
    required this.data,
    required this.isSelected,
    required this.onSelect,
    required this.onViewDetail,
    required this.onMatch,
  });

  final ContestCardData data;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onViewDetail;
  final VoidCallback onMatch;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: AppTheme.cardDecoration().copyWith(
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.contestName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (data.skillTags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: data.skillTags
                    .map((tag) => _tag(tag))
                    .toList(),
              ),
            const SizedBox(height: 14),
            _row('我擅长', data.skills),
            const SizedBox(height: 8),
            _row('每周可投入', data.availableTime),
            const SizedBox(height: 8),
            _row('希望队友', data.teammateExpect),
            const Spacer(),
            const Divider(color: AppTheme.divider, height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewDetail,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.secondaryBtnBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusBtn),
                      ),
                    ),
                    child: const Text('查看详情'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onMatch,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusBtn),
                      ),
                    ),
                    child: const Text('AI匹配'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.mintSoft,
        borderRadius: BorderRadius.circular(AppTheme.radiusTag),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppTheme.primary),
      ),
    );
  }

  Widget _row(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textSecondary),
        children: [
          TextSpan(
            text: '$label  ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
