import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Tip güvenli içerik bloğu render'ı (TASK 056 §3/§12).
///
/// Serbest HTML/Markdown YOKTUR: her blok türü kendi güvenli bileşenine
/// eşlenir. Okuma alanı sadedir — uzun metin arkasına illüstrasyon veya
/// yoğun motif KONULMAZ.
class LearnSectionView extends StatelessWidget {
  const LearnSectionView({super.key, required this.section});

  final LearningSection section;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s4),
      child: switch (section.type) {
        // Düz okuma metni.
        LearningSectionType.paragraph => AppText(section.text!),

        // Sıralı adımlar — pratik konularda (abdest vb.) numaralı gösterilir.
        LearningSectionType.steps => _NumberedList(items: section.items),

        // İşaretli liste.
        LearningSectionType.checklist => _BulletList(items: section.items),

        // Vurgu: sakin adaçayı yüzey.
        LearningSectionType.keyPoint => _Callout(
          text: section.text!,
          background: tokens.sageSurface,
        ),

        // Uyarı da SAKİNDİR: kırmızı/korku tonu kullanılmaz.
        LearningSectionType.warning => _Callout(
          text: section.text!,
          background: tokens.sandSurface,
          icon: Icons.info_outline,
        ),

        // Görüş farkı GİZLENMEZ; ayrı ve görünür bir blokta durur.
        LearningSectionType.differenceOfOpinion => _Callout(
          text: section.text!,
          background: tokens.sectionSurface,
          icon: Icons.balance_outlined,
        ),

        // Küçük pratik adım — davetkâr, baskı kurmayan.
        LearningSectionType.practicalAction => _Callout(
          text: section.text!,
          background: tokens.sandSurface,
          icon: Icons.eco_outlined,
        ),

        // Kaynak/atıf notu ve referanslar sakin, ikincil metindir.
        LearningSectionType.sourceNote ||
        LearningSectionType.quranReference ||
        LearningSectionType.hadithReference => AppText(
          section.text!,
          token: AppTextStyleToken.caption,
          secondary: true,
        ),
      },
    );
  }
}

class _NumberedList extends StatelessWidget {
  const _NumberedList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sıra numarası sakin bir tonal daire içinde.
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tokens.sageSurface,
                    borderRadius: AppRadius.smAll,
                  ),
                  child: AppText(
                    '${i + 1}',
                    token: AppTextStyleToken.caption,
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(child: AppText(items[i])),
              ],
            ),
          ),
      ],
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s1),
                  child: Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: tokens.spiritualGreenStrong,
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(child: AppText(item)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Tonal vurgu kutusu — gölgesiz, sakin.
class _Callout extends StatelessWidget {
  const _Callout({
    required this.text,
    required this.background,
    this.icon,
  });

  final String text;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.lgAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: tokens.spiritualGreenStrong),
              const SizedBox(width: AppSpacing.s3),
            ],
            Expanded(child: AppText(text)),
          ],
        ),
      ),
    );
  }
}
