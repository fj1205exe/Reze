import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'utils/gd.dart' as gd;
import 'utils/sgd.dart' as sgd;
import 'utils/neuralnet.dart' as nn;
import 'utils/bayes.dart' as bay;
import 'utils/classification.dart' as cl;
import 'utils/probability.dart' as pr;
import 'utils/content.dart';

import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/goal_screen.dart';
import 'screens/diagnostic_screen.dart';
import 'screens/skill_map_screen.dart';
import 'screens/recommended_start_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_tab.dart';
import 'screens/progress_tab.dart';
import 'screens/gd_play.dart';
import 'screens/gd_discover.dart';
import 'screens/gd_explain.dart';
import 'screens/gd_challenge.dart';
import 'screens/result_screen.dart';
import 'screens/lr_play.dart';
import 'screens/lr_explain.dart';
import 'screens/lr_result.dart';
import 'screens/of_play.dart';
import 'screens/of_explain.dart';
import 'screens/of_result.dart';
import 'screens/lf_play.dart';
import 'screens/lf_explain.dart';
import 'screens/lf_result.dart';
import 'screens/sgd_play.dart';
import 'screens/sgd_explain.dart';
import 'screens/sgd_result.dart';
import 'screens/vec_play.dart';
import 'screens/vec_explain.dart';
import 'screens/vec_result.dart';
import 'screens/dot_play.dart';
import 'screens/dot_explain.dart';
import 'screens/dot_result.dart';
import 'screens/cl_play.dart';
import 'screens/cl_explain.dart';
import 'screens/cl_result.dart';
import 'screens/pr_play.dart';
import 'screens/pr_explain.dart';
import 'screens/pr_result.dart';
import 'screens/bay_play.dart';
import 'screens/bay_explain.dart';
import 'screens/bay_result.dart';
import 'screens/nn_play.dart';
import 'screens/nn_explain.dart';
import 'screens/nn_result.dart';
import 'screens/bp_play.dart';
import 'screens/bp_explain.dart';
import 'screens/bp_result.dart';
import 'screens/lr_discover.dart';
import 'screens/lr_challenge.dart';
import 'screens/of_discover.dart';
import 'screens/of_challenge.dart';
import 'screens/lf_discover.dart';
import 'screens/lf_challenge.dart';
import 'screens/sgd_discover.dart';
import 'screens/sgd_challenge.dart';
import 'screens/vec_discover.dart';
import 'screens/vec_challenge.dart';
import 'screens/dot_discover.dart';
import 'screens/dot_challenge.dart';
import 'screens/cl_discover.dart';
import 'screens/cl_challenge.dart';
import 'screens/pr_discover.dart';
import 'screens/pr_challenge.dart';
import 'screens/bay_discover.dart';
import 'screens/bay_challenge.dart';
import 'screens/nn_discover.dart';
import 'screens/nn_challenge.dart';
import 'screens/bp_discover.dart';
import 'screens/bp_challenge.dart';

const int maxHistory = 12;

enum ComprehensionLevel { beginner, intermediate, advanced }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  runApp(const MLabApp());
}

class MLabApp extends StatelessWidget {
  const MLabApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MLab',
      theme: mlabTheme(),
      debugShowCheckedModeBanner: false,
      home: const MLabHome(),
    );
  }
}

enum AppScreen {
  splash,
  welcome,
  goal,
  diagnostic,
  skillmap,
  recommend,
  gdPlay,
  gdDiscover,
  gdExplain,
  gdChallenge,
  result,
  home,
  mapTab,
  progress,
  lrPlay,
  lrDiscover,
  lrExplain,
  lrChallenge,
  lrResult,
  ofPlay,
  ofDiscover,
  ofExplain,
  ofChallenge,
  ofResult,
  lfPlay,
  lfDiscover,
  lfExplain,
  lfChallenge,
  lfResult,
  sgdPlay,
  sgdDiscover,
  sgdExplain,
  sgdChallenge,
  sgdResult,
  vecPlay,
  vecDiscover,
  vecExplain,
  vecChallenge,
  vecResult,
  dotPlay,
  dotDiscover,
  dotExplain,
  dotChallenge,
  dotResult,
  clPlay,
  clDiscover,
  clExplain,
  clChallenge,
  clResult,
  prPlay,
  prDiscover,
  prExplain,
  prChallenge,
  prResult,
  bayPlay,
  bayDiscover,
  bayExplain,
  bayChallenge,
  bayResult,
  nnPlay,
  nnDiscover,
  nnExplain,
  nnChallenge,
  nnResult,
  bpPlay,
  bpDiscover,
  bpExplain,
  bpChallenge,
  bpResult,
}

class LRState {
  double slope;
  double intercept;
  int steps;
  double lr;
  LRState({
    this.slope = 0,
    this.intercept = 0.5,
    this.steps = 0,
    this.lr = 0.1,
  });
}

class OFState {
  int degree;
  int steps;
  OFState({this.degree = 3, this.steps = 0});
}

class LFState {
  String selectedLoss;
  double prediction;
  LFState({this.selectedLoss = 'mse', this.prediction = 0.2});
}

class SGDState {
  double theta;
  List<double> history;
  int steps;
  double lr;
  sgd.BatchSize batchSize;
  SGDState({
    required this.theta,
    List<double>? history,
    this.steps = 0,
    this.lr = 0.3,
    this.batchSize = sgd.BatchSize.mini,
  }) : history = history ?? [];
  factory SGDState.init() => SGDState(theta: gd.playStart);
}

class VECState {
  double ax, ay, bx, by;
  bool showSum, showDiff;
  VECState({
    this.ax = 0.8,
    this.ay = 0.6,
    this.bx = -0.4,
    this.by = 0.7,
    this.showSum = false,
    this.showDiff = false,
  });
}

class DOTState {
  double angleA, angleB, magA, magB;
  int steps;
  DOTState({
    this.angleA = 30,
    this.angleB = 100,
    this.magA = 1.0,
    this.magB = 0.9,
    this.steps = 0,
  });
}

class ActivityItem {
  final String concept, action, detail;
  final int colorValue;
  final int ts;
  ActivityItem({
    required this.concept,
    required this.action,
    required this.detail,
    required this.colorValue,
    required this.ts,
  });
  Map<String, dynamic> toJson() => {
    'concept': concept,
    'action': action,
    'detail': detail,
    'color': colorValue,
    'ts': ts,
  };
  factory ActivityItem.fromJson(Map<String, dynamic> j) => ActivityItem(
    concept: j['concept'] ?? '',
    action: j['action'] ?? '',
    detail: j['detail'] ?? '',
    colorValue: j['color'] ?? 0xFF4ADE80,
    ts: j['ts'] ?? 0,
  );
}

class AppProgress {
  bool gdComplete, lrComplete, ofComplete, lfComplete, sgdComplete;
  bool clComplete, prComplete, vecComplete, dotComplete;
  bool bayComplete, nnComplete, bpComplete;
  ComprehensionLevel comprehensionLevel;
  String goal;
  Map<String, int> skillMap;
  List<ActivityItem> history;

  AppProgress({
    this.gdComplete = false,
    this.lrComplete = false,
    this.ofComplete = false,
    this.lfComplete = false,
    this.sgdComplete = false,
    this.clComplete = false,
    this.prComplete = false,
    this.vecComplete = false,
    this.dotComplete = false,
    this.bayComplete = false,
    this.nnComplete = false,
    this.bpComplete = false,
    this.comprehensionLevel = ComprehensionLevel.beginner,
    this.goal = '',
    Map<String, int>? skillMap,
    List<ActivityItem>? history,
  }) : skillMap =
           skillMap ??
           {
             'Algebra': 0,
             'Functions': 0,
             'Vectors': 0,
             'Probability': 0,
             'Statistics': 0,
             'Calculus': 0,
             'Optimization': 0,
           },
       history = history ?? [];

  bool getFlag(String flag) {
    switch (flag) {
      case 'gdComplete':
        return gdComplete;
      case 'lrComplete':
        return lrComplete;
      case 'ofComplete':
        return ofComplete;
      case 'lfComplete':
        return lfComplete;
      case 'sgdComplete':
        return sgdComplete;
      case 'clComplete':
        return clComplete;
      case 'prComplete':
        return prComplete;
      case 'vecComplete':
        return vecComplete;
      case 'dotComplete':
        return dotComplete;
      case 'bayComplete':
        return bayComplete;
      case 'nnComplete':
        return nnComplete;
      case 'bpComplete':
        return bpComplete;
      default:
        return false;
    }
  }

  void setFlag(String flag, bool val) {
    switch (flag) {
      case 'gdComplete':
        gdComplete = val;
      case 'lrComplete':
        lrComplete = val;
      case 'ofComplete':
        ofComplete = val;
      case 'lfComplete':
        lfComplete = val;
      case 'sgdComplete':
        sgdComplete = val;
      case 'clComplete':
        clComplete = val;
      case 'prComplete':
        prComplete = val;
      case 'vecComplete':
        vecComplete = val;
      case 'dotComplete':
        dotComplete = val;
      case 'bayComplete':
        bayComplete = val;
      case 'nnComplete':
        nnComplete = val;
      case 'bpComplete':
        bpComplete = val;
    }
  }

  Map<String, dynamic> toJson() => {
    'gdComplete': gdComplete,
    'lrComplete': lrComplete,
    'ofComplete': ofComplete,
    'lfComplete': lfComplete,
    'sgdComplete': sgdComplete,
    'clComplete': clComplete,
    'prComplete': prComplete,
    'vecComplete': vecComplete,
    'dotComplete': dotComplete,
    'bayComplete': bayComplete,
    'nnComplete': nnComplete,
    'bpComplete': bpComplete,
    'comprehensionLevel': comprehensionLevel.name,
    'goal': goal,
    'skillMap': skillMap,
    'history': history.map((h) => h.toJson()).toList(),
  };

  factory AppProgress.fromJson(Map<String, dynamic> j) {
    final sm = <String, int>{
      'Algebra': 0,
      'Functions': 0,
      'Vectors': 0,
      'Probability': 0,
      'Statistics': 0,
      'Calculus': 0,
      'Optimization': 0,
    };
    if (j['skillMap'] is Map) {
      (j['skillMap'] as Map).forEach((k, v) {
        final saved = (v is int) ? v : (v as num).toInt();
        final key = k.toString();
        sm[key] = max(sm[key] ?? 0, saved);
      });
    }
    final hist = (j['history'] is List)
        ? (j['history'] as List)
              .take(12)
              .map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
              .toList()
        : <ActivityItem>[];
    final levelStr = j['comprehensionLevel'] as String? ?? 'beginner';
    final level = ComprehensionLevel.values.firstWhere(
      (e) => e.name == levelStr,
      orElse: () => ComprehensionLevel.beginner,
    );
    return AppProgress(
      gdComplete: j['gdComplete'] == true,
      lrComplete: j['lrComplete'] == true,
      ofComplete: j['ofComplete'] == true,
      lfComplete: j['lfComplete'] == true,
      sgdComplete: j['sgdComplete'] == true,
      clComplete: j['clComplete'] == true,
      prComplete: j['prComplete'] == true,
      vecComplete: j['vecComplete'] == true,
      dotComplete: j['dotComplete'] == true,
      bayComplete: j['bayComplete'] == true,
      nnComplete: j['nnComplete'] == true,
      bpComplete: j['bpComplete'] == true,
      comprehensionLevel: level,
      goal: j['goal'] as String? ?? '',
      skillMap: sm,
      history: hist,
    );
  }
}

class MLabHome extends StatefulWidget {
  const MLabHome({super.key});
  @override
  State<MLabHome> createState() => _MLabHomeState();
}

class _MLabHomeState extends State<MLabHome> {
  AppScreen _screen = AppScreen.splash;
  String _goal = '';
  bool _goingBack = false;

  int _gdRoundsPassed = 0;
  int _gdTotalRounds = 3;
  int _gdTotalSteps = 0;
  late LRState _lr;
  late OFState _of;
  late LFState _lf;
  late SGDState _sgd;
  late VECState _vec;
  late DOTState _dot;
  late cl.CLState _cl;
  late pr.PRState _pr;
  late bay.BAYState _bay;
  late nn.NNState _nn;
  late nn.BPState _bp;
  late AppProgress _progress;
  int _vecSteps = 0;
  int _clSteps = 0;
  int _baySteps = 0;
  int _nnSteps = 0;

  bool _lfChalSuccess = false;
  int _lfChalCorrect = 0;
  int _lfChalTotal = 5;
  bool _sgdChalSuccess = false;
  int _sgdChalSteps = 0;
  double _sgdChalLoss = 0;
  bool _bayChalSuccess = false;
  int _bayChalCorrect = 0;
  int _bayChalTotal = 3;
  bool _nnChalSuccess = false;
  int _nnChalAttempts = 0;
  bool _bpChalSuccess = false;
  int _bpChalCorrect = 0;
  @override
  void initState() {
    super.initState();
    _lr = LRState();
    _of = OFState();
    _lf = LFState();
    _sgd = SGDState.init();
    _vec = VECState();
    _dot = DOTState();
    _cl = const cl.CLState();
    _pr = const pr.PRState();
    _bay = bay.bayInit;
    _nn = nn.nnInit;
    _bp = nn.bpInit;
    _progress = AppProgress();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('mlab_progress');
    if (raw != null) {
      try {
        final saved = AppProgress.fromJson(jsonDecode(raw));
        setState(() {
          _progress = saved;
          final flags = [
            'gdComplete',
            'lrComplete',
            'ofComplete',
            'lfComplete',
            'sgdComplete',
            'clComplete',
            'prComplete',
            'vecComplete',
            'dotComplete',
            'bayComplete',
            'nnComplete',
            'bpComplete',
          ];
          final hasProgress =
              _progress.history.isNotEmpty ||
              flags.any((f) => _progress.getFlag(f));
          if (hasProgress) _screen = AppScreen.home;
        });
      } catch (_) {
        await SharedPreferences.getInstance()
            .then((p) => p.remove('mlab_progress'));
      }
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mlab_progress', jsonEncode(_progress.toJson()));
    } catch (_) {}
  }

  void _nav(AppScreen s) => setState(() {
    _goingBack = false;
    _screen = s;
  });
  void _back(AppScreen s) => setState(() {
    _goingBack = true;
    _screen = s;
  });

  void _addHistory(String concept, String action, String detail, int color) {
    _progress.history.insert(
      0,
      ActivityItem(
        concept: concept,
        action: action,
        detail: detail,
        colorValue: color,
        ts: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (_progress.history.length > maxHistory)
      _progress.history = _progress.history.sublist(0, maxHistory);
  }

  void _completeConcept(
    String flag,
    String concept,
    String detail,
    Map<String, int> gains,
  ) {
    if (_progress.getFlag(flag)) return;
    _progress.setFlag(flag, true);
    gains.forEach((skill, gain) {
      _progress.skillMap[skill] = min(
        100,
        (_progress.skillMap[skill] ?? 0) + gain,
      );
    });
    _addHistory(concept, 'Concept completed', detail, 0xFF4ADE80);
    _saveProgress();
  }

  void _completeGD(int roundsPassed, int totalRounds, int totalSteps) {
    setState(() {
      _gdRoundsPassed = roundsPassed;
      _gdTotalSteps = totalSteps;
      _gdTotalRounds = totalRounds;
    });
    if (roundsPassed >= 2) {
      _completeConcept(
        'gdComplete',
        'Gradient Descent',
        '$roundsPassed/$totalRounds rounds · $totalSteps steps',
        {'Optimization': 8, 'Calculus': 4},
      );
    }
  }

  void _completeLR() => setState(
    () => _completeConcept(
      'lrComplete',
      'Linear Regression',
      '+10 Optimization · +12 Statistics',
      {'Optimization': 10, 'Statistics': 12},
    ),
  );
  void _completeOF() => setState(
    () => _completeConcept(
      'ofComplete',
      'Overfitting',
      '+14 Statistics · +6 Calculus',
      {'Statistics': 14, 'Calculus': 6},
    ),
  );
  void _completeLF() => setState(
    () => _completeConcept(
      'lfComplete',
      'Loss Functions',
      '+10 Optimization · +8 Calculus',
      {'Optimization': 10, 'Calculus': 8},
    ),
  );
  void _completeSGD() => setState(
    () => _completeConcept(
      'sgdComplete',
      'SGD',
      '+12 Optimization · +5 Calculus',
      {'Optimization': 12, 'Calculus': 5},
    ),
  );
  void _completeVEC() => setState(
    () => _completeConcept(
      'vecComplete',
      'Vectors',
      '+14 Calculus · +10 Algebra',
      {'Calculus': 14, 'Algebra': 10},
    ),
  );
  void _completeDOT() => setState(
    () => _completeConcept(
      'dotComplete',
      'Dot Product',
      '+16 Vectors · +8 Calculus',
      {'Vectors': 16, 'Calculus': 8},
    ),
  );
  void _completeCL() => setState(
    () => _completeConcept(
      'clComplete',
      'Classification',
      '+12 Statistics · +8 Optimization',
      {'Statistics': 12, 'Optimization': 8},
    ),
  );
  void _completePR() => setState(
    () => _completeConcept(
      'prComplete',
      'Probability',
      '+14 Probability · +6 Statistics',
      {'Probability': 14, 'Statistics': 6},
    ),
  );
  void _completeBAY() => setState(
    () => _completeConcept(
      'bayComplete',
      "Bayes' Theorem",
      '+16 Probability · +10 Statistics',
      {'Probability': 16, 'Statistics': 10},
    ),
  );
  void _completeNN() => setState(
    () => _completeConcept(
      'nnComplete',
      'Weights & Bias',
      '+18 Calculus · +10 Optimization',
      {'Calculus': 18, 'Optimization': 10},
    ),
  );
  void _completeBP() => setState(
    () => _completeConcept(
      'bpComplete',
      'Backpropagation',
      '+20 Calculus · +15 Optimization',
      {'Calculus': 20, 'Optimization': 15},
    ),
  );

  // LR helpers
  void _lrGradientStep(double s, double i) {
    setState(() {
      _lr.slope = s;
      _lr.intercept = i;
      _lr.steps++;
    });
  }

  // SGD helpers
  void _sgdMakeStep() {
    setState(() {
      final next = gd.clamp(
        sgd.sgdStep(_sgd.theta, _sgd.lr, _sgd.batchSize),
        gd.tMin,
        gd.tMax,
      );
      _sgd.history.add(_sgd.theta);
      _sgd.theta = next;
      _sgd.steps++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LevelProvider(
      level: _progress.comprehensionLevel,
      child: Scaffold(
        backgroundColor: C.bg,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 380),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final slide =
                Tween<Offset>(
                  begin: Offset(_goingBack ? -0.15 : 0.15, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                );
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: _buildScreen(),
        ),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_screen) {
      // Onboarding
      case AppScreen.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onNext: () => _nav(AppScreen.welcome),
        );
      case AppScreen.welcome:
        return WelcomeScreen(
          key: const ValueKey('welcome'),
          onNext: () => _nav(AppScreen.goal),
        );
      case AppScreen.goal:
        return GoalScreen(
          key: const ValueKey('goal'),
          goal: _goal,
          onSelect: (g) => setState(() => _goal = g),
          onNext: () => _nav(AppScreen.diagnostic),
          onBack: () => _back(AppScreen.welcome),
        );
      case AppScreen.diagnostic:
        return DiagnosticScreen(
          key: const ValueKey('diag'),
          onBack: () => _back(AppScreen.goal),
          onNext: (level) {
            setState(() {
              _progress.comprehensionLevel = level;
              _progress.goal = _goal;
              _addHistory(
                'About You',
                'Comprehension profile',
                level.name,
                0xFF8B5CF6,
              );
            });
            _saveProgress();
            _nav(AppScreen.home);
          },
        );
      case AppScreen.skillmap:
        return SkillMapScreen(
          key: const ValueKey('skillmap'),
          skillMap: _progress.skillMap,
          mode: 'explore',
          onNext: () => _nav(AppScreen.home),
          onBack: () => _back(AppScreen.home),
        );
      case AppScreen.recommend:
        return RecommendedStartScreen(
          key: const ValueKey('rec'),
          onNext: () => _nav(AppScreen.gdPlay),
          onBack: () => _back(AppScreen.skillmap),
        );

      // GD flow
      case AppScreen.gdPlay:
        return GDPlayScreen(
          key: const ValueKey('gd-play'),
          onNext: () => _nav(AppScreen.gdDiscover),
          onBack: () => _back(AppScreen.home),
        );
      case AppScreen.gdDiscover:
        return GDDiscoverScreen(
          key: const ValueKey('gd-disc'),
          onNext: () => _nav(AppScreen.gdExplain),
          onBack: () => _back(AppScreen.gdPlay),
        );
      case AppScreen.gdExplain:
        return GDExplainScreen(
          key: const ValueKey('gd-exp'),
          onNext: () => _nav(AppScreen.gdChallenge),
          onBack: () => _back(AppScreen.gdDiscover),
        );
      case AppScreen.gdChallenge:
        return GDChallengeScreen(
          key: const ValueKey('gd-ch'),
          onComplete: (passed, total, steps) {
            _completeGD(passed, total, steps);
            _nav(AppScreen.result);
          },
          onBack: () => _back(AppScreen.gdExplain),
        );
      case AppScreen.result:
        return ResultScreen(
          key: const ValueKey('result'),
          roundsPassed: _gdRoundsPassed,
          totalRounds: _gdTotalRounds,
          totalSteps: _gdTotalSteps,
          succeeded: _gdRoundsPassed >= 2,
          onNext: () => _nav(AppScreen.home),
          onPlayLR: () {
            _lr = LRState();
            _nav(AppScreen.lrPlay);
          },
          onRetry: () => _nav(AppScreen.gdChallenge),
        );

      // LR flow
      case AppScreen.lrPlay:
        return LRPlayScreen(
          key: const ValueKey('lr-play'),
          slope: _lr.slope,
          intercept: _lr.intercept,
          steps: _lr.steps,
          onUpdate: (s, i) => setState(() {
            _lr.slope = s;
            _lr.intercept = i;
          }),
          onNext: () => _nav(AppScreen.lrDiscover),
          onBack: () => _back(AppScreen.home),
        );
      case AppScreen.lrDiscover:
        return LRDiscoverScreen(
          key: const ValueKey('lr-disc'),
          slope: _lr.slope,
          intercept: _lr.intercept,
          lr: _lr.lr,
          steps: _lr.steps,
          onUpdate: (s, i) => setState(() {
            _lr.slope = s;
            _lr.intercept = i;
          }),
          onGradientStep: _lrGradientStep,
          onLrChange: (v) => setState(() => _lr.lr = v),
          onNext: () => _nav(AppScreen.lrExplain),
          onBack: () => _back(AppScreen.lrPlay),
        );
      case AppScreen.lrExplain:
        return LRExplainScreen(
          key: const ValueKey('lr-exp'),
          slope: _lr.slope,
          intercept: _lr.intercept,
          onNext: () => _nav(AppScreen.lrChallenge),
          onBack: () => _back(AppScreen.lrDiscover),
        );
      case AppScreen.lrChallenge:
        return LRChallengeScreen(
          key: const ValueKey('lr-ch'),
          slope: _lr.slope,
          intercept: _lr.intercept,
          steps: _lr.steps,
          onUpdate: (s, i) => setState(() {
            _lr.slope = s;
            _lr.intercept = i;
            _lr.steps++;
          }),
          onNext: () {
            _completeLR();
            _nav(AppScreen.lrResult);
          },
          onBack: () => _back(AppScreen.lrExplain),
        );
      case AppScreen.lrResult:
        return LRResultScreen(
          key: const ValueKey('lr-res'),
          progress: _progress,
          onNext: () => _nav(AppScreen.home),
          onPlayOF: () {
            _of = OFState();
            _nav(AppScreen.ofPlay);
          },
        );

      // OF flow
      case AppScreen.ofPlay:
        return OFPlayScreen(
          key: const ValueKey('of-play'),
          degree: _of.degree,
          onUpdate: (d) => setState(() => _of.degree = d),
          onNext: () => _nav(AppScreen.ofDiscover),
          onBack: () => _back(AppScreen.home),
        );
      case AppScreen.ofDiscover:
        return OFDiscoverScreen(
          key: const ValueKey('of-disc'),
          degree: _of.degree,
          steps: _of.steps,
          onUpdate: (d) => setState(() {
            _of.degree = d;
            _of.steps++;
          }),
          onNext: () => _nav(AppScreen.ofExplain),
          onBack: () => _back(AppScreen.ofPlay),
        );
      case AppScreen.ofExplain:
        return OFExplainScreen(
          key: const ValueKey('of-exp'),
          degree: _of.degree,
          onNext: () => _nav(AppScreen.ofChallenge),
          onBack: () => _back(AppScreen.ofDiscover),
        );
      case AppScreen.ofChallenge:
        return OFChallengeScreen(
          key: const ValueKey('of-ch'),
          degree: _of.degree,
          steps: _of.steps,
          onUpdate: (d) => setState(() {
            _of.degree = d;
            _of.steps++;
          }),
          onNext: () {
            _completeOF();
            _nav(AppScreen.ofResult);
          },
          onBack: () => _back(AppScreen.ofExplain),
        );
      case AppScreen.ofResult:
        return OFResultScreen(
          key: const ValueKey('of-res'),
          progress: _progress,
          onNext: () => _nav(AppScreen.home),
          onPlayLF: () {
            _lf = LFState();
            _nav(AppScreen.lfPlay);
          },
        );

      // LF flow
      case AppScreen.lfPlay:
        return LFPlayScreen(
          key: const ValueKey('lf-play'),
          selectedLoss: _lf.selectedLoss,
          prediction: _lf.prediction,
          onUpdate: (pred, loss) => setState(() {
            _lf.prediction = pred;
            _lf.selectedLoss = loss;
          }),
          onNext: () => _nav(AppScreen.lfDiscover),
          onBack: () => _back(AppScreen.home),
        );
      case AppScreen.lfDiscover:
        return LFDiscoverScreen(
          key: const ValueKey('lf-disc'),
          selectedLoss: _lf.selectedLoss,
          prediction: _lf.prediction,
          onUpdate: (pred, loss) => setState(() {
            _lf.prediction = pred;
            _lf.selectedLoss = loss;
          }),
          onNext: () => _nav(AppScreen.lfExplain),
          onBack: () => _back(AppScreen.lfPlay),
        );
      case AppScreen.lfExplain:
        return LFExplainScreen(
          key: const ValueKey('lf-exp'),
          selectedLoss: _lf.selectedLoss,
          prediction: _lf.prediction,
          onNext: () => _nav(AppScreen.lfChallenge),
          onBack: () => _back(AppScreen.lfDiscover),
        );
      case AppScreen.lfChallenge:
        return LFChallengeScreen(
          key: const ValueKey('lf-ch'),
          onComplete: (success, correct, total) {
            setState(() {
              _lfChalSuccess = success;
              _lfChalCorrect = correct;
              _lfChalTotal = total;
            });
            _completeLF();
            _nav(AppScreen.lfResult);
          },
          onBack: () => _back(AppScreen.lfExplain),
        );
      case AppScreen.lfResult:
        return LFResultScreen(
          key: const ValueKey('lf-res'),
          progress: _progress,
          challengeSuccess: _lfChalSuccess,
          challengeCorrect: _lfChalCorrect,
          challengeTotal: _lfChalTotal,
          onRetryChallenge: () => _nav(AppScreen.lfChallenge),
          onNext: () => _nav(AppScreen.home),
          onPlaySGD: () {
            _sgd = SGDState.init();
            _nav(AppScreen.sgdPlay);
          },
        );

      // SGD flow
      case AppScreen.sgdPlay:
        return SGDPlayScreen(
          key: const ValueKey('sgd-play'),
          theta: _sgd.theta,
          history: _sgd.history,
          steps: _sgd.steps,
          lr: _sgd.lr,
          batchSize: _sgd.batchSize,
          onStep: _sgdMakeStep,
          onLrChange: (v) => setState(() => _sgd.lr = v),
          onBatchChange: (b) => setState(() => _sgd.batchSize = b),
          onNext: () => _nav(AppScreen.sgdDiscover),
          onBack: () => _back(AppScreen.home),
        );
      case AppScreen.sgdDiscover:
        return SGDDiscoverScreen(
          key: const ValueKey('sgd-disc'),
          theta: _sgd.theta,
          history: _sgd.history,
          lr: _sgd.lr,
          batchSize: _sgd.batchSize,
          onStep: _sgdMakeStep,
          onLrChange: (v) => setState(() => _sgd.lr = v),
          onBatchChange: (b) => setState(() => _sgd.batchSize = b),
          onNext: () => _nav(AppScreen.sgdExplain),
          onBack: () => _back(AppScreen.sgdPlay),
        );
      case AppScreen.sgdExplain:
        return SGDExplainScreen(
          key: const ValueKey('sgd-exp'),
          theta: _sgd.theta,
          history: _sgd.history,
          batchSize: _sgd.batchSize,
          onNext: () => _nav(AppScreen.sgdChallenge),
          onBack: () => _back(AppScreen.sgdDiscover),
        );
      case AppScreen.sgdChallenge:
        return SGDChallengeScreen(
          key: const ValueKey('sgd-ch'),
          onComplete: (success, steps, loss) {
            setState(() {
              _sgdChalSuccess = success;
              _sgdChalSteps = steps;
              _sgdChalLoss = loss;
            });
            _completeSGD();
            _nav(AppScreen.sgdResult);
          },
          onBack: () => _back(AppScreen.sgdExplain),
        );
      case AppScreen.sgdResult:
        return SGDResultScreen(
          key: const ValueKey('sgd-res'),
          progress: _progress,
          challengeSuccess: _sgdChalSuccess,
          challengeSteps: _sgdChalSteps,
          challengeFinalLoss: _sgdChalLoss,
          onRetryChallenge: () => _nav(AppScreen.sgdChallenge),
          onNext: () => _nav(AppScreen.home),
          onPlayCL: () {
            setState(() => _cl = const cl.CLState());
            _nav(AppScreen.clPlay);
          },
        );

      // VEC flow
      case AppScreen.vecPlay:
        return VECPlayScreen(
          key: const ValueKey('vec-play'),
          ax: _vec.ax,
          ay: _vec.ay,
          bx: _vec.bx,
          by: _vec.by,
          showSum: _vec.showSum,
          showDiff: _vec.showDiff,
          onUpdateA: (x, y) => setState(() {
            _vec.ax = x;
            _vec.ay = y;
          }),
          onUpdateB: (x, y) => setState(() {
            _vec.bx = x;
            _vec.by = y;
          }),
          onToggleSum: () => setState(() => _vec.showSum = !_vec.showSum),
          onToggleDiff: () => setState(() => _vec.showDiff = !_vec.showDiff),
          onNext: () => _nav(AppScreen.vecDiscover),
          onBack: () => _back(AppScreen.home),
        );
      case AppScreen.vecDiscover:
        return VECDiscoverScreen(
          key: const ValueKey('vec-disc'),
          ax: _vec.ax,
          ay: _vec.ay,
          bx: _vec.bx,
          by: _vec.by,
          showSum: _vec.showSum,
          showDiff: _vec.showDiff,
          onUpdateA: (x, y) => setState(() {
            _vec.ax = x;
            _vec.ay = y;
            _vecSteps++;
          }),
          onUpdateB: (x, y) => setState(() {
            _vec.bx = x;
            _vec.by = y;
            _vecSteps++;
          }),
          onToggleSum: () => setState(() => _vec.showSum = !_vec.showSum),
          onToggleDiff: () => setState(() => _vec.showDiff = !_vec.showDiff),
          onNext: () => _nav(AppScreen.vecExplain),
          onBack: () => _back(AppScreen.vecPlay),
        );
      case AppScreen.vecExplain:
        return VECExplainScreen(
          key: const ValueKey('vec-exp'),
          ax: _vec.ax,
          ay: _vec.ay,
          bx: _vec.bx,
          by: _vec.by,
          onNext: () => _nav(AppScreen.vecChallenge),
          onBack: () => _back(AppScreen.vecDiscover),
        );
      case AppScreen.vecChallenge:
        return VECChallengeScreen(
          key: const ValueKey('vec-ch'),
          ax: _vec.ax,
          ay: _vec.ay,
          targetMag: 5.0,
          steps: _vecSteps,
          onUpdateA: (x, y) => setState(() {
            _vec.ax = x;
            _vec.ay = y;
            _vecSteps++;
          }),
          onNext: () {
            _completeVEC();
            _nav(AppScreen.vecResult);
          },
          onBack: () => _back(AppScreen.vecExplain),
          onRetry: () => setState(() {
            _vec.ax = 1;
            _vec.ay = 0;
            _vecSteps = 0;
          }),
        );
      case AppScreen.vecResult:
        return VECResultScreen(
          key: const ValueKey('vec-res'),
          progress: _progress,
          onNext: () => _nav(AppScreen.home),
          onPlayDOT: () {
            _dot = DOTState();
            _nav(AppScreen.dotPlay);
          },
        );

      // DOT flow
      case AppScreen.dotPlay:
        return DOTPlayScreen(
          key: const ValueKey('dot-play'),
          angleA: _dot.angleA,
          angleB: _dot.angleB,
          magA: _dot.magA,
          magB: _dot.magB,
          onUpdate: (aA, aB, mA, mB) => setState(() {
            _dot.angleA = aA;
            _dot.angleB = aB;
            _dot.magA = mA;
            _dot.magB = mB;
          }),
          onNext: () => _nav(AppScreen.dotDiscover),
          onBack: () => _back(AppScreen.home),
        );
      case AppScreen.dotDiscover:
        return DOTDiscoverScreen(
          key: const ValueKey('dot-disc'),
          angleA: _dot.angleA,
          angleB: _dot.angleB,
          magA: _dot.magA,
          magB: _dot.magB,
          steps: _dot.steps,
          onUpdate: (aA, aB, mA, mB) => setState(() {
            _dot.angleA = aA;
            _dot.angleB = aB;
            _dot.magA = mA;
            _dot.magB = mB;
            _dot.steps++;
          }),
          onNext: () => _nav(AppScreen.dotExplain),
          onBack: () => _back(AppScreen.dotPlay),
        );
      case AppScreen.dotExplain:
        return DOTExplainScreen(
          key: const ValueKey('dot-exp'),
          angleA: _dot.angleA,
          angleB: _dot.angleB,
          magA: _dot.magA,
          magB: _dot.magB,
          onNext: () => _nav(AppScreen.dotChallenge),
          onBack: () => _back(AppScreen.dotDiscover),
        );
      case AppScreen.dotChallenge:
        return DOTChallengeScreen(
          key: const ValueKey('dot-ch'),
          angleA: _dot.angleA,
          angleB: _dot.angleB,
          magA: _dot.magA,
          magB: _dot.magB,
          steps: _dot.steps,
          onUpdate: (aA, aB, mA, mB) => setState(() {
            _dot.angleA = aA;
            _dot.angleB = aB;
            _dot.magA = mA;
            _dot.magB = mB;
            _dot.steps++;
          }),
          onNext: () {
            _completeDOT();
            _nav(AppScreen.dotResult);
          },
          onBack: () => _back(AppScreen.dotExplain),
        );
      case AppScreen.dotResult:
        return DOTResultScreen(
          key: const ValueKey('dot-res'),
          progress: _progress,
          onNext: () => _nav(AppScreen.home),
          onPlayPR: () {
            setState(() => _pr = const pr.PRState());
            _nav(AppScreen.prPlay);
          },
        );

      // CL flow
      case AppScreen.clPlay:
        return CLPlayScreen(
          key: const ValueKey('cl-play'),
          angle: _cl.angle,
          offset: _cl.offset,
          onUpdate: (a, o) =>
              setState(() => _cl = cl.CLState(angle: a, offset: o)),
          onNext: () => _nav(AppScreen.clDiscover),
          onBack: () => _back(AppScreen.home),
        );
      case AppScreen.clDiscover:
        return CLDiscoverScreen(
          key: const ValueKey('cl-disc'),
          angle: _cl.angle,
          offset: _cl.offset,
          onUpdate: (a, o) => setState(() {
            _cl = cl.CLState(angle: a, offset: o);
            _clSteps++;
          }),
          onNext: () => _nav(AppScreen.clExplain),
          onBack: () => _back(AppScreen.clPlay),
        );
      case AppScreen.clExplain:
        return CLExplainScreen(
          key: const ValueKey('cl-exp'),
          onNext: () => _nav(AppScreen.clChallenge),
          onBack: () => _back(AppScreen.clDiscover),
        );
      case AppScreen.clChallenge:
        return CLChallengeScreen(
          key: const ValueKey('cl-ch'),
          angle: _cl.angle,
          offset: _cl.offset,
          steps: _clSteps,
          onUpdate: (a, o) => setState(() {
            _cl = cl.CLState(angle: a, offset: o);
            _clSteps++;
          }),
          onNext: () {
            _completeCL();
            _nav(AppScreen.clResult);
          },
          onBack: () => _back(AppScreen.clExplain),
        );
      case AppScreen.clResult:
        return CLResultScreen(
          key: const ValueKey('cl-res'),
          progress: _progress,
          onNext: () => _nav(AppScreen.home),
          onPlayPR: () {
            setState(() => _pr = const pr.PRState());
            _nav(AppScreen.prPlay);
          },
        );

      // PR flow
      case AppScreen.prPlay:
        return PRPlayScreen(
          key: const ValueKey('pr-play'),
          p: _pr.p,
          flips: _pr.flips,
          onFlip: () => setState(
            () => _pr = _pr.copyWith(flips: [..._pr.flips, pr.flip(_pr.p)]),
          ),
          onFlipMany: (n) => setState(() {
            final newFlips = List.generate(n, (_) => pr.flip(_pr.p));
            _pr = _pr.copyWith(flips: [..._pr.flips, ...newFlips]);
          }),
          onChangeP: (p) => setState(() => _pr = pr.PRState(p: p)),
          onReset: () => setState(() => _pr = _pr.copyWith(flips: [])),
          onNext: () => _nav(AppScreen.prDiscover),
          onBack: () => _back(AppScreen.home),
        );
      case AppScreen.prDiscover:
        return PRDiscoverScreen(
          key: const ValueKey('pr-disc'),
          p: _pr.p,
          flips: _pr.flips,
          onFlip: () => setState(
            () => _pr = _pr.copyWith(flips: [..._pr.flips, pr.flip(_pr.p)]),
          ),
          onFlipMany: (n) => setState(() {
            final newFlips = List.generate(n, (_) => pr.flip(_pr.p));
            _pr = _pr.copyWith(flips: [..._pr.flips, ...newFlips]);
          }),
          onChangeP: (p) => setState(() => _pr = pr.PRState(p: p)),
          onReset: () => setState(() => _pr = _pr.copyWith(flips: [])),
          onNext: () => _nav(AppScreen.prExplain),
          onBack: () => _back(AppScreen.prPlay),
        );
      case AppScreen.prExplain:
        return PRExplainScreen(
          key: const ValueKey('pr-exp'),
          p: _pr.p,
          flips: _pr.flips,
          onNext: () => _nav(AppScreen.prChallenge),
          onBack: () => _back(AppScreen.prDiscover),
        );
      case AppScreen.prChallenge:
        return PRChallengeScreen(
          key: const ValueKey('pr-ch'),
          onNext: () {
            _completePR();
            _nav(AppScreen.prResult);
          },
          onBack: () => _back(AppScreen.prExplain),
        );
      case AppScreen.prResult:
        return PRResultScreen(
          key: const ValueKey('pr-res'),
          progress: _progress,
          onNext: () => _nav(AppScreen.home),
          onPlayBAY: () {
            setState(() => _bay = bay.bayInit);
            _nav(AppScreen.bayPlay);
          },
        );

      // BAY flow
      case AppScreen.bayPlay:
        return BAYPlayScreen(
          key: const ValueKey('bay-play'),
          prior: _bay.prior,
          sensitivity: _bay.sensitivity,
          specificity: _bay.specificity,
          onUpdate: (p, se, sp) => setState(
            () =>
                _bay = bay.BAYState(prior: p, sensitivity: se, specificity: sp),
          ),
          onNext: () => _nav(AppScreen.bayDiscover),
          onBack: () => _back(AppScreen.home),
        );
      case AppScreen.bayDiscover:
        return BAYDiscoverScreen(
          key: const ValueKey('bay-disc'),
          prior: _bay.prior,
          sensitivity: _bay.sensitivity,
          specificity: _bay.specificity,
          steps: _baySteps,
          onUpdate: (p, se, sp) => setState(() {
            _bay = bay.BAYState(prior: p, sensitivity: se, specificity: sp);
            _baySteps++;
          }),
          onNext: () => _nav(AppScreen.bayExplain),
          onBack: () => _back(AppScreen.bayPlay),
        );
      case AppScreen.bayExplain:
        return BAYExplainScreen(
          key: const ValueKey('bay-exp'),
          prior: _bay.prior,
          sensitivity: _bay.sensitivity,
          specificity: _bay.specificity,
          onNext: () => _nav(AppScreen.bayChallenge),
          onBack: () => _back(AppScreen.bayDiscover),
        );
      case AppScreen.bayChallenge:
        return BAYChallengeScreen(
          key: const ValueKey('bay-ch'),
          steps: _baySteps,
          onComplete: (success, correct, total) {
            setState(() {
              _bayChalSuccess = success;
              _bayChalCorrect = correct;
              _bayChalTotal = total;
            });
            _completeBAY();
            _nav(AppScreen.bayResult);
          },
          onBack: () => _back(AppScreen.bayExplain),
        );
      case AppScreen.bayResult:
        return BAYResultScreen(
          key: const ValueKey('bay-res'),
          progress: _progress,
          challengeSuccess: _bayChalSuccess,
          challengeCorrect: _bayChalCorrect,
          challengeTotal: _bayChalTotal,
          onRetryChallenge: () => _nav(AppScreen.bayChallenge),
          onNext: () => _nav(AppScreen.home),
          onPlayNN: () {
            setState(() => _nn = nn.nnInit);
            _nav(AppScreen.nnPlay);
          },
        );

      // NN flow
      case AppScreen.nnPlay:
        return NNPlayScreen(
          key: const ValueKey('nn-play'),
          w1: _nn.w1,
          w2: _nn.w2,
          bias: _nn.bias,
          x1: _nn.x1,
          x2: _nn.x2,
          onUpdate: (w1, w2, b) =>
              setState(() => _nn = _nn.copyWith(w1: w1, w2: w2, bias: b)),
          onNext: () => _nav(AppScreen.nnDiscover),
          onBack: () => _back(AppScreen.home),
        );
      case AppScreen.nnDiscover:
        return NNDiscoverScreen(
          key: const ValueKey('nn-disc'),
          w1: _nn.w1,
          w2: _nn.w2,
          bias: _nn.bias,
          x1: _nn.x1,
          x2: _nn.x2,
          steps: _nnSteps,
          onUpdate: (w1, w2, b) => setState(() {
            _nn = _nn.copyWith(w1: w1, w2: w2, bias: b);
            _nnSteps++;
          }),
          onNext: () => _nav(AppScreen.nnExplain),
          onBack: () => _back(AppScreen.nnPlay),
        );
      case AppScreen.nnExplain:
        return NNExplainScreen(
          key: const ValueKey('nn-exp'),
          w1: _nn.w1,
          w2: _nn.w2,
          bias: _nn.bias,
          x1: _nn.x1,
          x2: _nn.x2,
          onNext: () => _nav(AppScreen.nnChallenge),
          onBack: () => _back(AppScreen.nnDiscover),
        );
      case AppScreen.nnChallenge:
        return NNChallengeScreen(
          key: const ValueKey('nn-ch'),
          onComplete: (success, attempts) {
            setState(() {
              _nnChalSuccess = success;
              _nnChalAttempts = attempts;
            });
            _completeNN();
            _nav(AppScreen.nnResult);
          },
          onBack: () => _back(AppScreen.nnExplain),
        );
      case AppScreen.nnResult:
        return NNResultScreen(
          key: const ValueKey('nn-res'),
          progress: _progress,
          challengeSuccess: _nnChalSuccess,
          challengeSteps: _nnChalAttempts,
          onRetryChallenge: () => _nav(AppScreen.nnChallenge),
          onNext: () => _nav(AppScreen.home),
          onPlayBP: () {
            setState(() => _bp = nn.bpInit);
            _nav(AppScreen.bpPlay);
          },
        );

      // BP flow
      case AppScreen.bpPlay:
        return BPPlayScreen(
          key: const ValueKey('bp-play'),
          bp: _bp,
          onStep: () =>
              setState(() => _bp = _bp.copyWith(step: min(4, _bp.step + 1))),
          onTrain: () => setState(
            () => _bp = _bp.copyWith(
              net: nn.networkStep(_bp.net, _bp.x1, _bp.x2, 0.3),
              trainSteps: _bp.trainSteps + 1,
            ),
          ),
          onReset: () => setState(() => _bp = nn.bpInit),
          onNext: () => _nav(AppScreen.bpDiscover),
          onBack: () => _back(AppScreen.nnResult),
        );
      case AppScreen.bpDiscover:
        return BPDiscoverScreen(
          key: const ValueKey('bp-disc'),
          bp: _bp,
          onStep: () =>
              setState(() => _bp = _bp.copyWith(step: min(4, _bp.step + 1))),
          onNext: () => _nav(AppScreen.bpExplain),
          onBack: () => _back(AppScreen.bpPlay),
        );
      case AppScreen.bpExplain:
        return BPExplainScreen(
          key: const ValueKey('bp-exp'),
          bp: _bp,
          onNext: () => _nav(AppScreen.bpChallenge),
          onBack: () => _back(AppScreen.bpDiscover),
        );
      case AppScreen.bpChallenge:
        return BPChallengeScreen(
          key: const ValueKey('bp-ch'),
          onComplete: (success, correct, _) {
            setState(() {
              _bpChalSuccess = success;
              _bpChalCorrect = correct;
            });
            _completeBP();
            _nav(AppScreen.bpResult);
          },
          onBack: () => _back(AppScreen.bpExplain),
        );
      case AppScreen.bpResult:
        return BPResultScreen(
          key: const ValueKey('bp-res'),
          progress: _progress,
          challengeSuccess: _bpChalSuccess,
          challengeCorrect: _bpChalCorrect,
          challengeTotal: 3,
          onRetryChallenge: () => _nav(AppScreen.bpChallenge),
          onNext: () => _nav(AppScreen.home),
        );

      // Main tabs
      case AppScreen.home:
        return HomeScreen(
          key: const ValueKey('home'),
          progress: _progress,
          onNavigate: (s) => _nav(s),
        );
      case AppScreen.mapTab:
        return MapTabScreen(
          key: const ValueKey('map'),
          progress: _progress,
          onNavigate: _nav,
        );
      case AppScreen.progress:
        return ProgressTabScreen(
          key: const ValueKey('prog'),
          skillMap: _progress.skillMap,
          progress: _progress,
          onNavigate: _nav,
        );
    }
  }
}
