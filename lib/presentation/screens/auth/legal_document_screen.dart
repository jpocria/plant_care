import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

/// Tela genérica para exibir documentos legais (Termos de Uso, Política de Privacidade, etc.)
class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final List<LegalSection> sections;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/auth/register');
            }
          },
        ),
        title: Text(title),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          itemCount: sections.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Última atualização: $lastUpdated',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withAlpha((0.5 * 255).round()),
                      ),
                    ),
                  ],
                ),
              );
            }
            final s = sections[i - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(height: 8),
                  ...s.paragraphs.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          p,
                          style: const TextStyle(
                              fontSize: 13, height: 1.5),
                        ),
                      )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class LegalSection {
  final String title;
  final List<String> paragraphs;
  const LegalSection({required this.title, required this.paragraphs});
}
