# Memory Match — RULES.md
_The authoritative rules for Memory Match (com.gameswajiha.memorymatch).
If the implementation ever conflicts with this document, fix the implementation._

## 1. Objective
Find every matching pair of cards on the table.
- **Solo (Relaxed):** clear the whole table in as few moves as possible.
- **Solo (Timed):** clear the whole table before the clock runs out.
- **Party (2–4 players, pass-and-play) / You vs Bot:** collect more pairs than
  every opponent.

## 2. Setup
- The deck is built from the chosen card-face style: N distinct faces are
  picked, each appearing exactly twice (N pairs), then shuffled with a
  uniform random shuffle.
- Grid tiers (difficulty): Easy 4×3 (6 pairs), Classic 4×4 (8 pairs),
  Hard 6×4 (12 pairs), Expert 6×6 (18 pairs). A face style must contain at
  least N faces for the chosen tier, or the game refuses to start with an
  explanatory message.
- Timed clocks: Easy 120s, Classic 180s, Hard 300s, Expert 420s.
- Every card starts face-down. In Party/Vs-Bot, turn order is the player
  list order, starting with player 1.

## 3. Turn order
- **Solo:** the single player flips two cards per turn, indefinitely.
- **Party / Vs Bot:** players take turns. A turn = flipping two cards.
  A **match** grants the same player another turn immediately. A **miss**
  passes the turn to the next player in order (wrapping around).
- The active player is always highlighted on the score chips; the turn
  banner narrates whose turn it is ("Aisha, pick two cards!"). The bot's
  turn is never silent: its flips animate visibly after a short "thinking"
  beat.

## 4. Legal moves
- Tap any face-down, unmatched card on your own turn to flip it face-up.
- A turn consists of exactly two flips.
- Flipping two cards of the same face = a **match**: the pair is collected,
  stays face-up in the winner's color, and (Party/Vs-Bot) the player goes again.
- Flipping two different faces = a **miss**: both cards stay face-up for a
  visible pause (~1.1s) so everyone can memorize them, then flip back.

## 5. Illegal moves
- Tapping a card that is already face-up or already matched: rejected
  (invalid sound, no state change).
- Tapping the same card twice as the two flips of one turn: the second tap
  is quietly ignored (it does not count as a flip and does not end the turn).
- Tapping any card while a pair is being settled (checking phase), while the
  game is paused, after game over, or during the bot's turn: rejected.
- Starting a game with fewer faces than the tier needs: blocked with a message.

## 6. Captures
Not applicable — there are no captures in Memory Match. A matched pair is
"collected" by the player who flipped it (their pair counter increases by 1).

## 7. Special rules
- **Streak:** consecutive matches by the current side build a streak
  (shown as "🔥 xN" from x2 up in solo). Any miss resets the streak to 0.
  The best streak of each game feeds the all-time best-streak stat.
- **Timed urgency:** the final 10 seconds tick audibly once per second and
  the clock chip turns red.
- **Match beat:** matched cards celebrate for ~650ms (gold flash + pop)
  before the turn continues; the match sound plays exactly once.
- **Pause:** pausing freezes the engine — the settle timer, bot timer and
  the timed clock all stop and resume with their remaining time preserved.
  Backgrounding the app auto-pauses.
- **Renameable players:** all four player slots (including the bot slot)
  have editable display names, persisted across restarts.

## 8. Scoring
- Solo Relaxed: the score is the **move count** (one move = one pair of
  flips). Fewer is better; the personal best is kept.
- Solo Timed: the score is **time used** on a win (lower is better; best kept)
  plus the move count.
- Party / Vs Bot: score = **pairs collected** per player (shown on the
  score chips). More is better.

## 9. Winning conditions
- Solo Relaxed: all pairs collected — always a win ("Table cleared!").
- Solo Timed: all pairs collected before the clock hits zero.
- Party: the player with the most pairs wins (ties are shared wins).
- Vs Bot: the human wins by collecting more pairs than the bot; the bot
  wins otherwise. A human win counts toward the win stat; a bot win does not.

## 10. Draw conditions
- Solo: no draws (Relaxed always ends in a win; Timed ends in win or loss).
- Party: a tie for most pairs is a shared victory, announced as "It's a tie!".
- Timed: if the clock expires with pairs remaining, the game is lost
  ("Out of time!"). If the board happens to complete on the final tick,
  the win stands.

## 11. AI strategy
The bot ("Card Shark" by default; renameable) watches every flip and
remembers seen-but-unmatched cards:
- **Easy:** no memory — picks uniformly at random among hidden cards.
- **Medium:** keeps a short working memory (forgets beyond ~6 seen cards)
  and recalls a known mate only ~55% of the time — beatable but observant.
- **Hard:** perfect memory — if it has seen both cards of a pair it always
  takes the mate; its first pick prefers a known pair.
- The bot acts through the same flip path as a human (visible animations,
  same settle timing) with a ~750ms "thinking" beat before each flip.
- The engine watchdog nudges the bot if its timer ever dies, so a bot turn
  can never freeze the game.

## 12. Edge cases
- The settle timer, bot timer and clock are engine-owned; a 1-second
  watchdog repairs any phase found without its expected live timer
  (checking → settle immediately; dead bot timer → nudge; dead clock →
  restart). Stuck states are impossible by construction.
- Pause during the checking phase preserves the remaining settle time
  (clamped to a sane range) and reschedules on resume.
- Clock expiry during the checking phase still settles the pair first;
  the win/loss is then decided by board completeness.
- A corrupted or missing settings store falls back to safe defaults
  (Walnut theme, Forest faces, Diamond back, Classic grid, Easy bot).
- Player names are stored as ONE order-preserving JSON string
  (`memorymatch_player_names_json`); legacy keys migrate once and are removed.

## 13. Test cases
1. Flip two matching cards → both stay face-up in gold, pair counter +1,
   same player goes again, streak +1, match sound plays once.
2. Flip two different cards → both stay visible ~1.1s, flip back with the
   lay-down knock, turn passes (party), streak resets, miss sound plays once.
3. Tap an already face-up card → rejected with invalid sound, no state change.
4. Tap the same card twice in one turn → second tap ignored, turn continues.
5. Party 3 players, all pairs taken 4-3-1 → "4-pair" player wins outright.
6. Party tie 4-4 → "It's a tie!" shared victory.
7. Timed Classic: clear with 5s left → win, time-used recorded.
8. Timed: clock hits 0 with pairs left → loss screen, no win stat.
9. Vs Bot (Hard): bot takes a known mate when it has seen both cards.
10. Pause mid-check → resume → pair settles correctly, clock preserved.
11. Background the app mid-game → engine pauses; foreground → resumes.
12. Rename players, kill the app, relaunch → names intact and in order.
13. Free account: pro themes/faces/backs/tiers/bot-hard show a lock and
    nudge to the Pro screen; nothing premium is selectable.
14. Expert grid with a 6-face custom set → blocked with an explanatory message.
