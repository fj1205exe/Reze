import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets.dart';

const _concepts = [
  {'key': 'gd', 'label': 'Gradient Descent'},
  {'key': 'lr', 'label': 'Linear Regression'},
  {'key': 'of', 'label': 'Overfitting'},
  {'key': 'lf', 'label': 'Loss Functions'},
  {'key': 'sgd', 'label': 'SGD'},
  {'key': 'cl', 'label': 'Classification'},
  {'key': 'vec', 'label': 'Vectors'},
  {'key': 'dot', 'label': 'Dot Product'},
  {'key': 'pr', 'label': 'Probability'},
  {'key': 'bay', 'label': "Bayes' Theorem"},
  {'key': 'nn', 'label': 'Weights & Bias'},
  {'key': 'bp', 'label': 'Backpropagation'},
];

class LeaderboardTabScreen extends StatefulWidget {
  final void Function(AppScreen s) onNavigate;
  const LeaderboardTabScreen({super.key, required this.onNavigate});

  @override
  State<LeaderboardTabScreen> createState() => _LeaderboardTabScreenState();
}

class _LeaderboardTabScreenState extends State<LeaderboardTabScreen> {
  int _selectedConcept = 0;
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() { _loading = false; _error = 'Sign in to see leaderboards.'; });
      return;
    }
    try {
      final concept = _concepts[_selectedConcept]['key'] as String;
      final data = await Supabase.instance.client
          .from('leaderboard')
          .select()
          .eq('concept', concept)
          .order('best_score', ascending: false)
          .limit(50);
      if (!mounted) return;
      setState(() {
        _rows = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = 'Could not load leaderboard.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Container(
      color: C.bg,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Leaderboard',
                      style: spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Top scores by concept',
                      style: inter(fontSize: 14, color: C.muted)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _concepts.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final selected = i == _selectedConcept;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedConcept = i);
                            _fetch();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected ? C.accent.withValues(alpha: 0.15) : C.surface,
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                color: selected ? C.accent : C.border,
                              ),
                            ),
                            child: Text(
                              _concepts[i]['label'] as String,
                              style: spaceGrotesk(
                                fontSize: 12,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                color: selected ? C.accentLight : C.muted,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: C.accent))
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(_error!, style: inter(fontSize: 14, color: C.muted)),
                        ),
                      )
                    : _rows.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.emoji_events_outlined, size: 48, color: C.muted),
                                const SizedBox(height: 12),
                                Text('No scores yet', style: inter(fontSize: 14, color: C.muted)),
                                const SizedBox(height: 4),
                                Text('Be the first to complete this challenge!',
                                    style: inter(fontSize: 12, color: C.muted)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _rows.length,
                            itemBuilder: (_, i) {
                              final row = _rows[i];
                              final isMe = user != null && row['user_id'] == user.id;
                              final name = (row['display_name'] as String?) ?? 'Anonymous';
                              final score = row['best_score'] as int? ?? 0;
                              final rank = i + 1;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isMe ? C.accent.withValues(alpha: 0.08) : C.surface,
                                  borderRadius: S.borderMd,
                                  border: Border.all(
                                    color: isMe ? C.accent.withValues(alpha: 0.3) : C.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 32,
                                      child: Text(
                                        rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '#$rank',
                                        style: rank <= 3
                                            ? const TextStyle(fontSize: 18)
                                            : mono(fontSize: 13, color: C.muted),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: spaceGrotesk(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: isMe ? C.accentLight : C.txt,
                                            ),
                                          ),
                                          if (isMe)
                                            Text('You', style: inter(fontSize: 11, color: C.accent)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '$score',
                                      style: mono(
                                        fontSize: 16,
                                        color: rank == 1 ? C.yellow : C.txt,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
          MLabNavBar(
            active: 'ranks',
            onNavigate: (id) {
              if (id == 'home') widget.onNavigate(AppScreen.home);
              if (id == 'map') widget.onNavigate(AppScreen.mapTab);
              if (id == 'progress') widget.onNavigate(AppScreen.progress);
            },
          ),
        ],
      ),
    );
  }
}
