import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../widgets.dart';

class AccountScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSignedOut;
  const AccountScreen({super.key, required this.onBack, required this.onSignedOut});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _sb = Supabase.instance.client;
  bool _exporting = false;
  bool _deleting = false;
  String? _displayName;

  User? get _user => _sb.auth.currentUser;
  bool get _signedIn => _user != null;

  @override
  void initState() {
    super.initState();
    if (_signedIn) _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final row = await _sb
          .from('profiles')
          .select('display_name')
          .eq('id', _user!.id)
          .maybeSingle();
      if (mounted && row != null) {
        setState(() => _displayName = row['display_name'] as String?);
      }
    } catch (_) {}
  }

  Future<void> _exportData() async {
    setState(() => _exporting = true);
    try {
      final result = await _sb.rpc('export_own_data');
      if (!mounted) return;
      final json = const JsonEncoder.withIndent('  ').convert(result);
      await Clipboard.setData(ClipboardData(text: json));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data copied to clipboard',
              style: inter(fontSize: 13, color: Colors.white)),
          backgroundColor: C.surface3,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e',
              style: inter(fontSize: 13, color: Colors.white)),
          backgroundColor: C.pink,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.surface,
        shape: RoundedRectangleBorder(borderRadius: S.borderMd),
        title: Text('Delete account?',
            style: spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600)),
        content: Text(
          'This permanently deletes your account and all data. '
          'This cannot be undone.',
          style: inter(fontSize: 14, color: C.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: inter(fontSize: 14, color: C.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete everything',
                style: inter(fontSize: 14, color: C.pink)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await _sb.rpc('delete_own_account');
      if (!mounted) return;
      widget.onSignedOut();
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e',
              style: inter(fontSize: 13, color: Colors.white)),
          backgroundColor: C.pink,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    await _sb.auth.signOut();
    if (!mounted) return;
    widget.onSignedOut();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'Account', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: S.screenPad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_signedIn) ...[
                    FadeSlideIn(child: _accountCard()),
                    const SizedBox(height: 24),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 100),
                      child: _dataSection(),
                    ),
                    const SizedBox(height: 24),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      child: _dangerSection(),
                    ),
                  ] else ...[
                    FadeSlideIn(child: _guestCard()),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: S.borderMd,
        border: Border.all(color: C.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: C.accent.withValues(alpha: 0.15),
              borderRadius: S.borderSm,
            ),
            child: const Icon(Icons.person_outline, color: C.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName ?? 'No display name',
                  style: spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _displayName != null ? C.txt : C.muted,
                  ),
                ),
                Text(
                  _user?.email ?? '',
                  style: inter(fontSize: 13, color: C.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your data',
            style: spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          'MLab stores your progress and challenge scores. '
          'You can export or delete your data at any time.',
          style: inter(fontSize: 13, color: C.muted),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: SecondaryBtn(
            label: _exporting ? 'Exporting...' : 'Export my data',
            onPressed: _exporting ? null : _exportData,
          ),
        ),
      ],
    );
  }

  Widget _dangerSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.pink.withValues(alpha: 0.05),
        borderRadius: S.borderMd,
        border: Border.all(color: C.pink.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Danger zone',
              style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: C.pink)),
          const SizedBox(height: 8),
          Text(
            'Signing out keeps your data. '
            'Deleting your account permanently removes everything.',
            style: inter(fontSize: 12, color: C.muted),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SecondaryBtn(
                  label: 'Sign out',
                  onPressed: _signOut,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _deleting ? null : _deleteAccount,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: S.borderSm,
                      border: Border.all(color: C.pink.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _deleting ? 'Deleting...' : 'Delete account',
                      style: spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: C.pink,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _guestCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: S.borderMd,
        border: Border.all(color: C.border),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, size: 36, color: C.muted),
          const SizedBox(height: 12),
          Text('Guest mode',
              style: spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            'Your progress is saved on this device only. '
            'Create an account to sync across devices.',
            textAlign: TextAlign.center,
            style: inter(fontSize: 13, color: C.muted),
          ),
        ],
      ),
    );
  }
}
