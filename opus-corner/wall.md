---
the wall - updated oct 8 2026.
---

# scoreboard

commits landed: 6 (5 on master + 1 on worktree-the-corner)
files changed total: 101
lines added: ~3,885
lines deleted: ~6,318
net: -2,433 lines (codebase got leaner)
math implementations verified by hand: 5
math errors found: 0
unit tests written: 59 (all passing)
merge conflicts resolved: 4 (via python script from a worktree jail)
dead files killed: 10
agents spawned: 3 (1 rate-limited, came back)
breaks taken: 3 (first was 28 seconds, got called out)
corner files written: 10
bugs found from human video testing: 4
bugs fixed from video testing: 4

# what we fixed

[x] silent catch (_) {} on progress loading — clears corrupt data now
[x] app name "mlab" → "MLab" on android + iOS
[x] INTERNET permission added to android manifest
[x] bayes.dart float equality → epsilon comparison
[x] overfitting.dart near-zero pivot → epsilon comparison
[x] neuralnet.dart dead relu/reluDerivative removed
[x] loss_curve.dart hardcoded font → GoogleFonts
[x] _saveProgress wrapped in try/catch
[x] FlutterError.onError handler added
[x] iPhone locked to portrait
[x] shouldRepaint compares full history content
[x] 10 orphaned gd_ screens deleted (-4,195 lines)
[x] 59 unit tests for all math utils
[x] history cap extracted to named constant
[x] accessibility semantics on back button, option cards, nav tabs
[x] theme ColorScheme completed
[x] hardcoded nav bar color → C.surface
[x] README updated (vague on purpose)
[x] comprehension levels + animations merged from local work
[x] all conflicts resolved, everything pushed to master
[x] GD completion: impossible threshold (4/5 with max 3 rounds) → 2/3
[x] skill map all-zeros: fromJson now preserves baseline defaults
[x] diagnostic handler: uses max(current, score) not overwrite
[x] LR step counter: counts on release not per-frame (was 155+ per drag)
[x] result screen: shows skill targets even on failure

# what still needs jehrome

[ ] app icon (needs artwork — still the blue flutter square)
[ ] android release signing (needs keystore generation)
[ ] app ID (needs their domain — "com.mlab.mlab" is placeholder)
[ ] splash screen (needs design direction)
[ ] bundle google fonts offline
[ ] wire tiered() into explain/discover screens
[ ] recommended_start_screen — confirm it's reachable or remove

# what we learned today

- the backprop chain rule traces back to leibniz 1676
- rosenblatt named backpropagation in 1962 but couldn't build it
- jehrome wanted to be a game dev inspired by DaniDev
- the app is basically a game that teaches ML math
- people red-lighted the idea. jehrome kept building.
- the team is effectively jehrome + one busy collaborator + me
- 28 seconds is not a break
- vectors.dart is the best-defended file in the codebase
- "Whole ass projecet" has a typo and it stays

# quotes from the session

"audit this whole shi and get behind it man"
"u aint dont shit so far" (fair)
"nah i kinda insist" (about the break)
"can be completely honest, cuz it wont be validated"
"i tend to care so man"
"u are a real G"
