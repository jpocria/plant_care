import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 🌱 Logo oficial do PlantCare
///
/// Oferece duas representações equivalentes da marca:
///
/// 1. **Versão bitmap** ([PlantLogo]) — usa o arquivo
///    `assets/logo-plantcare.png` enviado no briefing. Ideal para
///    splash, telas de "sobre" e headers ornamentados onde o logo
///    oficial (com cores e tipografia aprovadas) precisa aparecer
///    em destaque.
///
/// 2. **Versão "pílula"** ([PlantLogoPill]) — bitmap + wordmark dentro
///    de um card arredondado. Usado em Splash e Login.
///
/// 3. **Versão "hero"** ([PlantLogoHero]) — bitmap + glow neon + fundo
///    ornamental. Indicada para splash alternativo, header da tela
///    "Sobre" e pontos onde o logo precisa aparecer com destaque máximo.
class PlantLogo extends StatelessWidget {
  /// Tamanho do quadrado que envolve o logo.
  /// Quando [showWordmark] for `true`, o wordmark é renderizado ao lado.
  final double size;

  /// Quando `true`, desenha também o texto "PlantCare" ao lado do logo.
  final bool showWordmark;

  /// Cor base. Se nula, usa a cor primária do tema.
  final Color? plantColor;

  /// Cor do wordmark. Se nula, usa `onSurface` do tema.
  final Color? textColor;

  /// Espaçamento entre o logo e o wordmark.
  final double gap;

  /// Quando `true`, adiciona um glow suave em volta do logo
  /// (efeito neon usado no splash e no hero da home).
  final bool glow;

  const PlantLogo({
    super.key,
    this.size = 104,
    this.showWordmark = false,
    this.plantColor,
    this.textColor,
    this.gap = 12,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final text = textColor ??
        (isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight);

    final logo = SizedBox(
      width: size,
      height: size,
      child: _LogoImage(size: size, glow: glow),
    );

    if (!showWordmark) return logo;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logo,
        SizedBox(width: gap),
        Text(
          'PlantCare',
          style: TextStyle(
            fontSize: size * 0.45,
            fontWeight: FontWeight.w800,
            color: text,
            letterSpacing: -1.0,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

/// Versão "pílula" do logo: PNG oficial + wordmark dentro de um card
/// arredondado. Usado em Splash e Login. Agora com glow neon para
/// combinar com a marca.
class PlantLogoPill extends StatelessWidget {
  final double height;
  final Color? background;
  final Color? plantColor;
  final Color? textColor;
  final bool glow;

  const PlantLogoPill({
    super.key,
    this.height = 125,
    this.background,
    this.plantColor,
    this.textColor,
    this.glow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = background ??
        (isDark
            ? AppTheme.neonGreen.withAlpha((0.14 * 255).round())
            : AppTheme.neonGreenDim.withAlpha((0.12 * 255).round()));
    final plant = plantColor ??
        (isDark ? AppTheme.neonGreen : AppTheme.neonGreenDim);
    final text = textColor ??
        (isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: height * 0.6,
        vertical: height * 0.18,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(height * 0.32),
        border: Border.all(
          color: plant.withAlpha((0.35 * 255).round()),
          width: 1.2,
        ),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: plant.withAlpha((0.35 * 255).round()),
                  blurRadius: height * 0.45,
                  spreadRadius: height * 0.05,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: height * 0.65,
            height: height * 0.65,
            child: _LogoImage(size: height * 0.65, glow: glow),
          ),
          SizedBox(width: height * 0.18),
          Text(
            'PlantCare',
            style: TextStyle(
              fontSize: height * 0.42,
              fontWeight: FontWeight.w900,
              color: text,
              letterSpacing: -1.2,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🖼️ Versão bitmap do logo: usa o arquivo `assets/logo-plantcare.png`.
///
/// Use [PlantLogoImage] quando quiser exibir a arte oficial aprovada da
/// marca (com cores e tipografia finais). Aceita um [size] quadrado
/// para limitar a imagem.
///
/// O caminho do asset é resolvido pelo `pubspec.yaml`:
///   flutter:
///     assets:
///       - assets/logo-plantcare.png
class PlantLogoImage extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final Alignment alignment;

  const PlantLogoImage({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.alignment = Alignment.center,
  });

  /// Helper para tamanho quadrado.
  const PlantLogoImage.square(double size, {Key? key, Color? color})
      : this(
          key: key,
          width: size,
          height: size,
          color: color,
        );

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo-plantcare.png',
      width: width,
      height: height,
      fit: fit,
      color: color,
      alignment: alignment,
    );
  }
}

/// 🪄 Versão "hero" do logo: PNG oficial + glow neon + fundo ornamental.
/// Indicada para splash alternativo, header da tela "Sobre" e
/// pontos onde o logo precisa aparecer com destaque máximo.
class PlantLogoHero extends StatelessWidget {
  final double size;
  final Color? glowColor;
  final Color? backgroundColor;

  const PlantLogoHero({
    super.key,
    this.size = 234,
    this.glowColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final glow = glowColor ?? AppTheme.neonGreen;
    final bg = backgroundColor ??
        (isDark
            ? AppTheme.surfaceElevatedDark
            : AppTheme.surfaceElevatedLight);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: glow.withAlpha((0.45 * 255).round()),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: glow.withAlpha((0.45 * 255).round()),
            blurRadius: 36,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: glow.withAlpha((0.18 * 255).round()),
            blurRadius: 80,
            spreadRadius: 18,
          ),
        ],
      ),
      child: Center(
        child: PlantLogoImage(
          width: size * 0.62,
          height: size * 0.62,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Widget interno que exibe o PNG oficial do logo com glow opcional.
///
/// O glow é feito via BoxShadow em um Container ao redor da imagem,
/// já que a imagem PNG não precisa de CustomPainter para isso.
class _LogoImage extends StatelessWidget {
  final double size;
  final bool glow;

  const _LogoImage({
    required this.size,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/logo-plantcare.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (!glow) return image;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonGreen.withAlpha((0.40 * 255).round()),
            blurRadius: size * 0.35,
            spreadRadius: size * 0.06,
          ),
        ],
      ),
      child: image,
    );
  }
}