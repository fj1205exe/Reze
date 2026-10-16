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

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
  String? _error;

  SupabaseClient get _sb => Supabase.instance.client;

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Email and password required.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      if (_isSignUp) {
        await _sb.auth.signUp(email: email, password: pass);
      } else {
        await _sb.auth.signInWithPassword(email: email, password: pass);
      }
      if (!mounted) return;
      widget.onAuthenticated();
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.bg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text('MLab',
                  style: spaceGrotesk(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: C.accent)),
              const SizedBox(height: 4),
              Text(
                _isSignUp ? 'Create your account' : 'Welcome back',
                style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in to sync progress across devices.',
                style: inter(fontSize: 14, color: C.muted),
              ),
              const SizedBox(height: 32),

              _label('Email'),
              const SizedBox(height: 6),
              _field(_emailCtrl, 'you@example.com', false),
              const SizedBox(height: 16),

              _label('Password'),
              const SizedBox(height: 6),
              _field(_passCtrl, '••••••', true),
              const SizedBox(height: 24),

              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: C.pink.withValues(alpha: 0.08),
                    borderRadius: S.borderSm,
                    border: Border.all(color: C.pink.withValues(alpha: 0.25)),
                  ),
                  child: Text(_error!,
                      style: inter(fontSize: 13, color: C.pink)),
                ),
                const SizedBox(height: 16),
              ],

              SizedBox(
                width: double.infinity,
                child: PrimaryBtn(
                  label: _loading
                      ? 'Loading...'
                      : (_isSignUp ? 'Create account' : 'Sign in'),
                  disabled: _loading,
                  onPressed: _loading ? null : _submit,
                ),
              ),
              const SizedBox(height: 12),

              Center(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isSignUp = !_isSignUp;
                    _error = null;
                  }),
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Sign in'
                        : 'No account? Create one',
                    style: inter(fontSize: 13, color: C.accent),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(child: Container(height: 1, color: C.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: inter(fontSize: 12, color: C.muted)),
                  ),
                  Expanded(child: Container(height: 1, color: C.border)),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: SecondaryBtn(
                  label: 'Continue as guest',
                  onPressed: widget.onContinueAsGuest,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Progress saved locally only',
                  style: inter(fontSize: 11, color: C.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500, color: C.muted),
      );

  Widget _field(TextEditingController ctrl, String hint, bool obscure) =>
      TextField(
        controller: ctrl,
        obscureText: obscure,
        style: inter(fontSize: 15, color: C.txt),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: inter(fontSize: 15, color: C.muted.withValues(alpha: 0.5)),
          filled: true,
          fillColor: C.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: C.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: C.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: C.accent),
          ),
        ),
      );
}
