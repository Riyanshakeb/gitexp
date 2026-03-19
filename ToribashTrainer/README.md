# Toribash Offline Trainer

A trainer tool for **Toribash's offline tutorial / single-player mode only**.
Modify game rules, physics, and install helper Lua scripts to make learning easier and more fun.

> **This trainer is for offline/tutorial mode only. Do NOT use in online multiplayer.**

## Features

### Quick Presets
| Preset | Effect |
|---|---|
| God Mode | Can't be dismembered |
| Glass Cannon | Everything shatters on contact |
| Moon Gravity | Low gravity, floaty fights |
| Zero Gravity | No gravity at all |
| Jupiter Gravity | Extreme heavy gravity |
| Slow Motion | Extended turns for practice |
| Infinite Time | Nearly unlimited match time |
| Tiny / Huge Arena | Adjust arena size |
| Sumo Mode | Push-off-ring wins, no dismemberment |
| Tutorial Easy | God mode + slow turns + light gravity (best for learning) |

### AI Memory Auto-Fighter
| Script | In-game command | Effect |
|---|---|---|
| `ai_fighter.lua` | `/ls ai_fighter` | Learns your moves for 10 rounds, then auto-fights using best combos |
| `ai_fighter_advanced.lua` | `/ls ai_fighter_advanced` | Advanced AI with combo dictionary, adaptive styles, persistent memory |

**How the AI works:**
1. **Learn Mode** (first 5-10 rounds): Play normally. The AI records every joint state and scores them by damage dealt.
2. **Fight Mode** (automatic): The AI mixes the best-scoring moves, mutates combos for variety, and adapts its style.
3. **Adaptive Styles**: Aggressive (arm attacks), Defensive (leg stability), Spin Kick, Uppercut — auto-selected based on what works.
4. **Persistent Memory**: Saves to `ai_memory.dat` — gets smarter across game sessions.

### Lua Scripts
| Script | In-game command | Effect |
|---|---|---|
| `practice_helper.lua` | `/ls practice_helper` | All-in-one: god mode + slow time + light gravity + auto-win |
| `god_mode.lua` | `/ls god_mode` | Indestructible Tori |
| `auto_win.lua` | `/ls auto_win` | Opponent collapses each round |
| `custom_gravity.lua` | `/ls custom_gravity` | Cycles gravity presets each round |
| `instant_dismember.lua` | `/ls instant_dismember` | One-hit dismemberment |
| `slow_time.lua` | `/ls slow_time` | Extended turns for learning |

## Usage

### Option 1: GUI Trainer (Python)
```
python toribash_trainer.py
```
- Set your Toribash game path
- Pick a preset or customize rules
- Click "Apply to Game"

### Option 2: Manual Lua Scripts
Copy the `.lua` files from `lua_scripts/` into your Toribash installation:
```
Toribash/data/script/
```
Then in-game, type `/ls practice_helper` (or any script name without `.lua`).

## Requirements
- Python 3.8+ with tkinter (for the GUI trainer)
- Toribash installed (Steam or standalone)
- Windows / macOS / Linux
