import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/wake_flow_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    required this.controller,
    required this.isDarkMode,
    required this.onToggleTheme,
    super.key,
  });

  final WakeFlowController controller;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _registerMode = false;
  var _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _AuthPalette.fromMode(widget.isDarkMode);

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: palette.background,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: palette.accent,
          selectionColor: palette.accent.withValues(alpha: 0.28),
          selectionHandleColor: palette.accent,
        ),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              _AuthBackdrop(palette: palette),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: <Widget>[
                    _ThemeToggleButton(
                      isDarkMode: widget.isDarkMode,
                      palette: palette,
                      onPressed: widget.onToggleTheme,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        widget.controller.signIn('local@wakeup.ai');
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(color: palette.accent),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(22, 54, 22, 28),
                    children: <Widget>[
                      _WakeLogo(palette: palette),
                      const SizedBox(height: 22),
                      Text(
                        _registerMode ? 'WakeUp AI-ға қосыл' : 'Қош келдің',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.text,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _registerMode
                            ? 'Таңғы тәртіпті бүгіннен баста'
                            : 'Оятқыш пен жаттығу жоспарың дайын',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.muted,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _ModeSwitch(
                        registerMode: _registerMode,
                        palette: palette,
                        onChanged: (value) {
                          setState(() => _registerMode = value);
                        },
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                            decoration: BoxDecoration(
                              color: palette.field,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: palette.border),
                            ),
                            child: const Text('🇰🇿 +7', style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _AuthField(
                              controller: _emailController,
                              hintText: 'Номер',
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_android_rounded,
                              palette: palette,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _AuthField(
                        controller: _passwordController,
                        hintText: 'Құпия сөз',
                        obscureText: _obscurePassword,
                        autofillHints: const <String>[AutofillHints.password],
                        prefixIcon: Icons.lock_outline_rounded,
                        palette: palette,
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword ? 'Көрсету' : 'Жасыру',
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: palette.muted,
                          ),
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Құпия сөзді ұмыттың ба?',
                            style: TextStyle(color: palette.accent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: palette.accent,
                            foregroundColor: palette.onAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _submit,
                          child: Text(
                            _registerMode ? 'Аккаунт ашу' : 'Кіру',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _DividerLabel(
                        label: 'Немесе жалғастыру',
                        palette: palette,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _SocialButton(
                              label: 'Google',
                              icon: Icons.g_mobiledata_rounded,
                              palette: palette,
                              onPressed: _submit,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SocialButton(
                              label: 'Apple',
                              icon: Icons.apple,
                              palette: palette,
                              onPressed: _submit,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _AuthFooter(
                        registerMode: _registerMode,
                        palette: palette,
                        onToggle: () {
                          setState(() => _registerMode = !_registerMode);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    await widget.controller.signIn(_emailController.text);
  }
}

class _AuthPalette {
  const _AuthPalette({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.field,
    required this.accent,
    required this.accentSoft,
    required this.text,
    required this.muted,
    required this.border,
    required this.onAccent,
    required this.socialBackground,
    required this.socialText,
  });

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color field;
  final Color accent;
  final Color accentSoft;
  final Color text;
  final Color muted;
  final Color border;
  final Color onAccent;
  final Color socialBackground;
  final Color socialText;

  factory _AuthPalette.fromMode(bool isDarkMode) {
    if (isDarkMode) {
      return _AuthPalette(
        background: WakeUpTheme.darkBackground,
        surface: WakeUpTheme.darkSurface,
        surfaceHigh: WakeUpTheme.darkSurfaceHigh,
        field: const Color(0xff151f45),
        accent: WakeUpTheme.darkPrimary,
        accentSoft: WakeUpTheme.darkSecondary,
        text: Colors.white,
        muted: const Color(0xffa9b3d3),
        border: Colors.white.withValues(alpha: 0.08),
        onAccent: Colors.white,
        socialBackground: Colors.white,
        socialText: const Color(0xff101827),
      );
    }

    return _AuthPalette(
      background: WakeUpTheme.lightBackground,
      surface: WakeUpTheme.lightSurface,
      surfaceHigh: const Color(0xffeaf0ff),
      field: Colors.white,
      accent: WakeUpTheme.lightPrimary,
      accentSoft: WakeUpTheme.lightSecondary,
      text: const Color(0xff111827),
      muted: const Color(0xff667085),
      border: Colors.black.withValues(alpha: 0.08),
      onAccent: Colors.white,
      socialBackground: Colors.white,
      socialText: const Color(0xff111827),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({
    required this.isDarkMode,
    required this.palette,
    required this.onPressed,
  });

  final bool isDarkMode;
  final _AuthPalette palette;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: isDarkMode ? 'Ақ режим' : 'Қара режим',
      style: IconButton.styleFrom(
        backgroundColor: palette.surfaceHigh,
        foregroundColor: palette.accentSoft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      icon: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop({required this.palette});

  final _AuthPalette palette;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  palette.background,
                  palette.surfaceHigh.withValues(alpha: 0.82),
                  palette.background,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 42,
          top: 106,
          child: _Spark(color: palette.accentSoft, size: 4),
        ),
        Positioned(
          right: 52,
          top: 142,
          child: _Spark(color: palette.accent, size: 5),
        ),
        Positioned(
          left: 68,
          bottom: 92,
          child: _Spark(color: palette.accent, size: 5),
        ),
        Positioned(
          right: 86,
          bottom: 152,
          child: _Spark(color: palette.accentSoft, size: 4),
        ),
      ],
    );
  }
}

class _Spark extends StatelessWidget {
  const _Spark({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
      child: SizedBox(width: size, height: size),
    );
  }
}

class _WakeLogo extends StatelessWidget {
  const _WakeLogo({required this.palette});

  final _AuthPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: palette.accent.withValues(alpha: 0.3)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: palette.accent.withValues(alpha: 0.28),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[palette.accentSoft, palette.accent],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'WakeUp AI',
          style: TextStyle(
            color: palette.text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({
    required this.registerMode,
    required this.palette,
    required this.onChanged,
  });

  final bool registerMode;
  final _AuthPalette palette;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ModeButton(
              label: 'Login',
              selected: !registerMode,
              palette: palette,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ModeButton(
              label: 'Get Started',
              selected: registerMode,
              palette: palette,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final _AuthPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? palette.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: palette.accent.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? palette.onAccent : palette.muted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.palette,
    this.keyboardType,
    this.autofillHints,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final _AuthPalette palette;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      style: TextStyle(color: palette.text),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: palette.muted),
        prefixIcon: Icon(prefixIcon, color: palette.muted),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: palette.field,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.accent, width: 1.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({
    required this.label,
    required this.palette,
  });

  final String label;
  final _AuthPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Divider(color: palette.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(color: palette.muted, fontSize: 12),
          ),
        ),
        Expanded(child: Divider(color: palette.border)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.palette,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final _AuthPalette palette;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.socialText,
          side: BorderSide(color: palette.border),
          backgroundColor: palette.socialBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: palette.socialText, size: 24),
        label: Text(
          label,
          style: TextStyle(
            color: palette.socialText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _AuthFooter extends StatelessWidget {
  const _AuthFooter({
    required this.registerMode,
    required this.palette,
    required this.onToggle,
  });

  final bool registerMode;
  final _AuthPalette palette;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          registerMode ? 'Аккаунтың бар ма? ' : 'Аккаунтың жоқ па? ',
          style: TextStyle(color: palette.muted),
        ),
        TextButton(
          onPressed: onToggle,
          child: Text(
            registerMode ? 'Кіру' : 'Тіркелу',
            style: TextStyle(
              color: palette.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
