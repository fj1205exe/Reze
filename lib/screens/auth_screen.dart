import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../widgets.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onContinueAsGuest;
  final VoidCallback onAuthenticated;
  const AuthScreen({
    super.key,
    required this.onContinueAsGuest,
    required this.onAuthenticated,
  });
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _isSignUp = false;
  bool _loading = false;
  bool _obscure = true;
  bool _authExpanded = false;
  String? _error;
  String? _info;

  SupabaseClient get _sb => Supabase.instance.client;

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _error = 'That doesn\'t look like an email.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password needs at least 6 characters.');
      return;
    }
    setState(() { _loading = true; _error = null; _info = null; });
    try {
      if (_isSignUp) {
        final res = await _sb.auth.signUp(email: email, password: pass);
        if (!mounted) return;
        if (res.session != null) {
          widget.onAuthenticated();
        } else {
          setState(() {
            _info = 'Check your email to confirm, then sign in.';
            _isSignUp = false;
          });
        }
      } else {
        await _sb.auth.signInWithPassword(email: email, password: pass);
        if (!mounted) return;
        widget.onAuthenticated();
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(e.message));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Connection failed. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('invalid login')) return 'Wrong email or password.';
    if (m.contains('already registered')) return 'Account exists — sign in instead.';
    if (m.contains('email not confirmed')) return 'Confirm your email first, then sign in.';
    if (m.contains('rate limit')) return 'Too many attempts. Wait a minute.';
    return msg;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      color: C.bg,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 16, bottom: bottom + 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - bottom - 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),

                    FadeSlideIn(
                      child: _brandSection(),
                    ),
                    const SizedBox(height: 40),

                    FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      child: _guestButton(),
                    ),
                    const SizedBox(height: 28),

                    FadeSlideIn(
                      delay: const Duration(milliseconds: 250),
                      child: _divider(),
                    ),
                    const SizedBox(height: 20),

                    FadeSlideIn(
                      delay: const Duration(milliseconds: 350),
                      child: _authSection(),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _brandSection() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                C.accent.withValues(alpha: 0.25),
                C.accent.withValues(alpha: 0.0),
              ],
            ),
          ),
          child: Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [C.accent, Color(0xFF6D28D9)],
                ),
              ),
              child: Center(
                child: Text('M',
                  style: spaceGrotesk(
                    fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('MLab',
          style: spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text('Learn ML by playing with the math.',
          style: inter(fontSize: 15, color: C.muted),
        ),
      ],
    );
  }

  Widget _guestButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: widget.onContinueAsGuest,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: S.borderMd,
              gradient: const LinearGradient(
                colors: [C.accent, Color(0xFF7C3AED)],
              ),
              boxShadow: [
                BoxShadow(
                  color: C.accent.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text('Start learning',
                  style: spaceGrotesk(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: Colors.white, letterSpacing: 0.02,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('No account needed',
          style: inter(fontSize: 12, color: C.muted),
        ),
      ],
    );
  }

  Widget _divider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: C.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or sync your progress',
            style: inter(fontSize: 12, color: C.muted),
          ),
        ),
        Expanded(child: Container(height: 1, color: C.border)),
      ],
    );
  }

  Widget _authSection() {
    if (!_authExpanded) {
      return GestureDetector(
        onTap: () => setState(() => _authExpanded = true),
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: S.borderMd,
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            color: C.surface,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 18, color: C.muted),
              const SizedBox(width: 8),
              Text('Sign in or create account',
                style: inter(fontSize: 13, fontWeight: FontWeight.w500, color: C.txt),
              ),
              const SizedBox(width: 6),
              Icon(Icons.keyboard_arrow_down, size: 18, color: C.muted),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: S.borderLg,
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _authToggle(),
          const SizedBox(height: 20),

          if (_info != null) ...[
            _infoBanner(_info!),
            const SizedBox(height: 14),
          ],

          if (_error != null) ...[
            _errorBanner(_error!),
            const SizedBox(height: 14),
          ],

          _inputField(
            controller: _emailCtrl,
            focusNode: _emailFocus,
            hint: 'Email',
            icon: Icons.mail_outline,
            obscure: false,
            inputAction: TextInputAction.next,
            onSubmit: (_) => _passFocus.requestFocus(),
            inputType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),

          _inputField(
            controller: _passCtrl,
            focusNode: _passFocus,
            hint: 'Password',
            icon: Icons.lock_outline,
            obscure: _obscure,
            inputAction: TextInputAction.done,
            onSubmit: (_) => _submit(),
            suffix: GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18, color: C.muted,
              ),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: PrimaryBtn(
              label: _loading
                  ? (_isSignUp ? 'Creating...' : 'Signing in...')
                  : (_isSignUp ? 'Create account' : 'Sign in'),
              disabled: _loading,
              onPressed: _loading ? null : _submit,
            ),
          ),

          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: () => setState(() {
                _authExpanded = false;
                _error = null;
                _info = null;
              }),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.keyboard_arrow_up, size: 16, color: C.muted),
                    const SizedBox(width: 4),
                    Text('Collapse', style: inter(fontSize: 12, color: C.muted)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _authToggle() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: C.bg,
        borderRadius: S.borderSm,
      ),
      child: Row(
        children: [
          _toggleTab('Sign in', !_isSignUp, () {
            setState(() { _isSignUp = false; _error = null; });
          }),
          _toggleTab('Create account', _isSignUp, () {
            setState(() { _isSignUp = true; _error = null; });
          }),
        ],
      ),
    );
  }

  Widget _toggleTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 38,
          decoration: BoxDecoration(
            color: active ? C.surface3 : Colors.transparent,
            borderRadius: S.borderSm,
          ),
          alignment: Alignment.center,
          child: Text(label,
            style: spaceGrotesk(
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? C.txt : C.muted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required bool obscure,
    TextInputAction? inputAction,
    ValueChanged<String>? onSubmit,
    TextInputType? inputType,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      textInputAction: inputAction,
      keyboardType: inputType,
      onSubmitted: onSubmit,
      style: inter(fontSize: 14, color: C.txt),
      cursorColor: C.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: inter(fontSize: 14, color: C.muted.withValues(alpha: 0.5)),
        prefixIcon: Icon(icon, size: 18, color: C.muted),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffix,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 36),
        filled: true,
        fillColor: C.bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: C.accent.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  Widget _errorBanner(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: C.pink.withValues(alpha: 0.08),
        borderRadius: S.borderSm,
        border: Border.all(color: C.pink.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: C.pink),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg, style: inter(fontSize: 13, color: C.pink)),
          ),
        ],
      ),
    );
  }

  Widget _infoBanner(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: C.blue.withValues(alpha: 0.08),
        borderRadius: S.borderSm,
        border: Border.all(color: C.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: C.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg, style: inter(fontSize: 13, color: C.blue)),
          ),
        ],
      ),
    );
  }
}
