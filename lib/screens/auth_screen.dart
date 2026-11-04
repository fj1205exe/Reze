import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../widgets.dart';
import 'legal_screen.dart';

enum _AuthStep { initial, otp, setupProfile }

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
  final _passConfirmCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _passConfirmFocus = FocusNode();
  final _nameFocus = FocusNode();
  final List<TextEditingController> _otpCtrls =
      List.generate(8, (_) => TextEditingController());
  final List<FocusNode> _otpFocuses = List.generate(8, (_) => FocusNode());

  bool _isSignUp = false;
  bool _loading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _authExpanded = false;
  String? _error;
  String? _info;
  _AuthStep _step = _AuthStep.initial;
  String _signupEmail = '';
  Timer? _resendTimer;
  int _resendCooldown = 0;

  SupabaseClient get _sb => Supabase.instance.client;

  Future<void> _sendOtp() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _error = 'That does not look like an email.');
      return;
    }
    setState(() { _loading = true; _error = null; _info = null; });
    try {
      await _sb.auth.signInWithOtp(email: email);
      if (!mounted) return;
      _signupEmail = email;
      _startResendTimer();
      setState(() {
        _step = _AuthStep.otp;
        _loading = false;
        _info = 'Code sent to $email';
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _otpFocuses[0].requestFocus();
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = _friendlyError(e.message); });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _error = 'Connection failed. Try again.'; });
    }
  }

  void _startResendTimer() {
    _resendCooldown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) t.cancel();
      });
    });
  }

  Future<void> _resendOtp() async {
    if (_resendCooldown > 0) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _sb.auth.signInWithOtp(email: _signupEmail);
      if (!mounted) return;
      _startResendTimer();
      setState(() { _loading = false; _info = 'New code sent.'; });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = _friendlyError(e.message); });
    } catch (e) {
      if (!mounted) return;
      debugPrint('Resend OTP failed: $e');
      setState(() { _loading = false; _error = 'Failed to resend. Try again.'; });
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpCtrls.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() => _error = 'Enter the full 6-digit code.');
      return;
    }
    setState(() { _loading = true; _error = null; _info = null; });
    try {
      await _sb.auth.verifyOTP(
        email: _signupEmail,
        token: code,
        type: OtpType.email,
      );
      if (!mounted) return;
      setState(() {
        _step = _AuthStep.setupProfile;
        _loading = false;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _nameFocus.requestFocus();
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = _friendlyError(e.message); });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _error = 'Verification failed. Try again.'; });
    }
  }

  Future<void> _completeProfile() async {
    final name = _nameCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _passConfirmCtrl.text;
    if (name.isEmpty) {
      setState(() => _error = 'Pick a display name.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password needs at least 6 characters.');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await _sb.auth.updateUser(
        UserAttributes(password: pass, data: {'display_name': name}),
      );
      if (!mounted) return;
      final user = _sb.auth.currentUser;
      if (user != null) {
        await _sb.from('profiles').upsert({
          'id': user.id,
          'display_name': name,
        });
      }
      if (!mounted) return;
      widget.onAuthenticated();
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = _friendlyError(e.message); });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _error = 'Something went wrong. Try again.'; });
    }
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _error = 'That does not look like an email.');
      return;
    }
    setState(() { _loading = true; _error = null; _info = null; });
    try {
      await _sb.auth.signInWithPassword(email: email, password: pass);
      if (!mounted) return;
      widget.onAuthenticated();
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = _friendlyError(e.message); });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _error = 'Connection failed. Try again.'; });
    }
  }

  String _friendlyError(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('invalid login')) return 'Wrong email or password.';
    if (m.contains('already registered')) return 'Account exists. Sign in instead.';
    if (m.contains('email not confirmed')) return 'Check your email for the verification code.';
    if (m.contains('rate limit')) return 'Too many attempts. Wait a minute.';
    if (m.contains('otp') && m.contains('expired')) return 'Code expired. Request a new one.';
    if (m.contains('invalid') && m.contains('otp')) return 'Wrong code. Check and try again.';
    return msg;
  }

  void _goBackToInitial() {
    for (final c in _otpCtrls) { c.clear(); }
    _passCtrl.clear();
    _passConfirmCtrl.clear();
    _nameCtrl.clear();
    _resendTimer?.cancel();
    setState(() {
      _step = _AuthStep.initial;
      _error = null;
      _info = null;
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _passConfirmCtrl.dispose();
    _nameCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _passConfirmFocus.dispose();
    _nameFocus.dispose();
    for (final c in _otpCtrls) { c.dispose(); }
    for (final f in _otpFocuses) { f.dispose(); }
    _resendTimer?.cancel();
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
              padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: bottom + 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - bottom - 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    FadeSlideIn(child: _brandSection()),
                    const SizedBox(height: 40),
                    if (_step == _AuthStep.initial) ...[
                      FadeSlideIn(delay: const Duration(milliseconds: 150), child: _guestButton()),
                      const SizedBox(height: 28),
                      FadeSlideIn(delay: const Duration(milliseconds: 250), child: _divider()),
                      const SizedBox(height: 20),
                      FadeSlideIn(delay: const Duration(milliseconds: 350), child: _authSection()),
                    ] else if (_step == _AuthStep.otp) ...[
                      FadeSlideIn(child: _otpSection()),
                    ] else if (_step == _AuthStep.setupProfile) ...[
                      FadeSlideIn(child: _profileSetupSection()),
                    ],
                    const SizedBox(height: 24),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 400),
                      child: _legalLinks(),
                    ),
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
    String subtitle;
    if (_step == _AuthStep.otp) {
      subtitle = 'Check your inbox for the code.';
    } else if (_step == _AuthStep.setupProfile) {
      subtitle = 'Almost there. Set up your profile.';
    } else {
      subtitle = 'Learn ML by playing with the math.';
    }
    return Column(
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              C.accent.withValues(alpha: 0.25),
              C.accent.withValues(alpha: 0.0),
            ]),
          ),
          child: Center(
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [C.accent, Color(0xFF6D28D9)],
                ),
              ),
              child: Center(
                child: _step == _AuthStep.otp
                    ? const Icon(Icons.mail_outline, color: Colors.white, size: 24)
                    : _step == _AuthStep.setupProfile
                        ? const Icon(Icons.person_outline, color: Colors.white, size: 24)
                        : Text('M', style: spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _step == _AuthStep.otp ? 'Verify your email'
              : _step == _AuthStep.setupProfile ? 'Welcome to MLab' : 'MLab',
          style: spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: inter(fontSize: 15, color: C.muted)),
      ],
    );
  }

  Widget _guestButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: widget.onContinueAsGuest,
          child: Container(
            width: double.infinity, height: 56,
            decoration: BoxDecoration(
              borderRadius: S.borderMd,
              gradient: const LinearGradient(colors: [C.accent, Color(0xFF7C3AED)]),
              boxShadow: [BoxShadow(color: C.accent.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text('Start learning', style: spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.02)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('No account needed', style: inter(fontSize: 12, color: C.muted)),
      ],
    );
  }

  Widget _divider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: C.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or sync your progress', style: inter(fontSize: 12, color: C.muted)),
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
          width: double.infinity, height: 48,
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
              Text('Sign in or create account', style: inter(fontSize: 13, fontWeight: FontWeight.w500, color: C.txt)),
              const SizedBox(width: 6),
              Icon(Icons.keyboard_arrow_down, size: 18, color: C.muted),
            ],
          ),
        ),
      );
    }
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.surface, borderRadius: S.borderLg,
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _authToggle(),
          const SizedBox(height: 20),
          if (_info != null) ...[_infoBanner(_info!), const SizedBox(height: 14)],
          if (_error != null) ...[_errorBanner(_error!), const SizedBox(height: 14)],
          _inputField(
            controller: _emailCtrl, focusNode: _emailFocus,
            hint: 'Email', icon: Icons.mail_outline, obscure: false,
            inputAction: _isSignUp ? TextInputAction.done : TextInputAction.next,
            onSubmit: (_) => _isSignUp ? _sendOtp() : _passFocus.requestFocus(),
            inputType: TextInputType.emailAddress,
          ),
          if (!_isSignUp) ...[
            const SizedBox(height: 12),
            _inputField(
              controller: _passCtrl, focusNode: _passFocus,
              hint: 'Password', icon: Icons.lock_outline, obscure: _obscure,
              inputAction: TextInputAction.done, onSubmit: (_) => _signIn(),
              suffix: GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: C.muted),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: PrimaryBtn(
              label: _loading
                  ? (_isSignUp ? 'Sending code...' : 'Signing in...')
                  : (_isSignUp ? 'Send verification code' : 'Sign in'),
              disabled: _loading,
              onPressed: _loading ? null : (_isSignUp ? _sendOtp : _signIn),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: () => setState(() { _authExpanded = false; _error = null; _info = null; }),
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
      height: 38, decoration: BoxDecoration(color: C.bg, borderRadius: S.borderSm),
      child: Row(
        children: [
          _toggleTab('Sign in', !_isSignUp, () => setState(() { _isSignUp = false; _error = null; _info = null; })),
          _toggleTab('Create account', _isSignUp, () => setState(() { _isSignUp = true; _error = null; _info = null; })),
        ],
      ),
    );
  }

  Widget _toggleTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), curve: Curves.easeOutCubic, height: 38,
          decoration: BoxDecoration(
            color: active ? C.surface3 : Colors.transparent, borderRadius: S.borderSm,
          ),
          alignment: Alignment.center,
          child: Text(label, style: spaceGrotesk(
            fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? C.txt : C.muted,
          )),
        ),
      ),
    );
  }

  Widget _otpSection() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.surface, borderRadius: S.borderLg,
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          if (_info != null) ...[_infoBanner(_info!), const SizedBox(height: 14)],
          if (_error != null) ...[_errorBanner(_error!), const SizedBox(height: 14)],
          Text('Enter the 6-digit code sent to', style: inter(fontSize: 14, color: C.muted)),
          const SizedBox(height: 4),
          Text(_signupEmail, style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(8, (i) => _otpDigitField(i))),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: PrimaryBtn(label: _loading ? 'Verifying...' : 'Verify', disabled: _loading, onPressed: _loading ? null : _verifyOtp),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _resendCooldown > 0 ? null : (_loading ? null : _resendOtp),
            child: Text(
              _resendCooldown > 0 ? 'Resend code in ${_resendCooldown}s' : 'Resend code',
              style: inter(fontSize: 13, color: _resendCooldown > 0 ? C.muted : C.accent),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _goBackToInitial,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, size: 14, color: C.muted),
                const SizedBox(width: 4),
                Text('Use a different email', style: inter(fontSize: 12, color: C.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpDigitField(int index) {
    return Container(
      width: 36, height: 48, margin: EdgeInsets.only(left: index > 0 ? 6 : 0),
      child: TextField(
        controller: _otpCtrls[index], focusNode: _otpFocuses[index],
        keyboardType: TextInputType.number, textAlign: TextAlign.center, maxLength: 1,
        style: mono(fontSize: 20, color: C.txt),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '', filled: true, fillColor: C.bg,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: C.accent.withValues(alpha: 0.5))),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 7) _otpFocuses[index + 1].requestFocus();
          if (val.isEmpty && index > 0) _otpFocuses[index - 1].requestFocus();
          if (index == 5 && val.isNotEmpty) {
            final code = _otpCtrls.map((c) => c.text).join();
            if (code.length == 8) _verifyOtp();
          }
        },
      ),
    );
  }

  Widget _profileSetupSection() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.surface, borderRadius: S.borderLg,
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null) ...[_errorBanner(_error!), const SizedBox(height: 14)],
          Text('Choose a display name', style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('This shows on leaderboards.', style: inter(fontSize: 12, color: C.muted)),
          const SizedBox(height: 12),
          _inputField(controller: _nameCtrl, focusNode: _nameFocus, hint: 'Display name', icon: Icons.badge_outlined, obscure: false, inputAction: TextInputAction.next, onSubmit: (_) => _passFocus.requestFocus()),
          const SizedBox(height: 20),
          Text('Set a password for next time', style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('At least 6 characters.', style: inter(fontSize: 12, color: C.muted)),
          const SizedBox(height: 12),
          _inputField(
            controller: _passCtrl, focusNode: _passFocus, hint: 'Password', icon: Icons.lock_outline, obscure: _obscure,
            inputAction: TextInputAction.next, onSubmit: (_) => _passConfirmFocus.requestFocus(),
            suffix: GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: C.muted),
            ),
          ),
          const SizedBox(height: 12),
          _inputField(
            controller: _passConfirmCtrl, focusNode: _passConfirmFocus, hint: 'Confirm password', icon: Icons.lock_outline, obscure: _obscureConfirm,
            inputAction: TextInputAction.done, onSubmit: (_) => _completeProfile(),
            suffix: GestureDetector(
              onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
              child: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: C.muted),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: PrimaryBtn(label: _loading ? 'Creating account...' : 'Finish setup', disabled: _loading, onPressed: _loading ? null : _completeProfile),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller, required FocusNode focusNode,
    required String hint, required IconData icon, required bool obscure,
    TextInputAction? inputAction, ValueChanged<String>? onSubmit,
    TextInputType? inputType, Widget? suffix,
  }) {
    return TextField(
      controller: controller, focusNode: focusNode, obscureText: obscure,
      textInputAction: inputAction, keyboardType: inputType, onSubmitted: onSubmit,
      style: inter(fontSize: 14, color: C.txt), cursorColor: C.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: inter(fontSize: 14, color: C.muted.withValues(alpha: 0.5)),
        prefixIcon: Icon(icon, size: 18, color: C.muted),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix) : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 36),
        filled: true, fillColor: C.bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: C.accent.withValues(alpha: 0.5))),
      ),
    );
  }

  Widget _errorBanner(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: C.pink.withValues(alpha: 0.08), borderRadius: S.borderSm, border: Border.all(color: C.pink.withValues(alpha: 0.2))),
      child: Row(children: [
        Icon(Icons.error_outline, size: 16, color: C.pink),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: inter(fontSize: 13, color: C.pink))),
      ]),
    );
  }

  Widget _infoBanner(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: C.blue.withValues(alpha: 0.08), borderRadius: S.borderSm, border: Border.all(color: C.blue.withValues(alpha: 0.2))),
      child: Row(children: [
        Icon(Icons.info_outline, size: 16, color: C.blue),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: inter(fontSize: 13, color: C.blue))),
      ]),
    );
  }

  Widget _legalLinks() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _showLegalSheet('Privacy Policy', privacyPolicyText),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text('Privacy Policy', style: inter(fontSize: 11, color: C.muted).copyWith(decoration: TextDecoration.underline)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text('·', style: inter(fontSize: 11, color: C.muted)),
          ),
          GestureDetector(
            onTap: () => _showLegalSheet('Terms of Service', termsOfServiceText),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text('Terms of Service', style: inter(fontSize: 11, color: C.muted).copyWith(decoration: TextDecoration.underline)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLegalSheet(String title, String body) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollCtrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: C.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(title, style: spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(body, style: inter(fontSize: 13, color: C.muted, height: 1.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
