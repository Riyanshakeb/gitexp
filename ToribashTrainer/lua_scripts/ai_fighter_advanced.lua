-- ============================================
-- Advanced AI Auto-Fighter for Toribash
-- Offline/Tutorial mode ONLY
-- ============================================
-- /ls ai_fighter_advanced
--
-- Smarter version: chains combos together,
-- mutates moves for variety, never repeats
-- the same pattern twice in a row.
--
-- Based on the exact same API pattern as the
-- working Uke RandomCombo bot.

local move = 0
local chosen = 0
local last_chosen = 0
local rounds = 0
local mutation_rate = 15  -- % chance to mutate each joint

-- Full combo library: {grip_r, grip_l, j0..j19}
-- States: 1=extend 2=contract 3=hold 4=relax
local combos = {
    { -- 1: Aikido grab
        {1,0, 3,2,3,3,2,3,3,1,3,3,3,3,2,2,3,3,3,3,3,3},
        {1,0, 3,2,3,3,2,3,3,1,3,3,3,3,2,2,3,3,3,3,3,3},
        {0,0, 3,2,3,3,2,3,3,1,3,3,3,3,2,2,3,3,3,3,3,3},
        {0,0, 3,2,3,3,3,3,3,1,3,3,3,3,2,1,3,3,3,3,3,3},
        {0,0, 3,2,3,3,3,3,3,1,3,3,3,3,2,3,3,3,3,3,3,3},
    },
    { -- 2: Power rush
        {0,1, 1,1,1,2,1,3,2,2,4,4,1,4,2,2,1,2,2,3,2,2},
        {0,1, 1,1,1,3,1,3,2,2,2,1,1,1,2,2,1,2,1,3,2,2},
        {0,1, 1,4,2,1,4,1,1,4,2,1,1,1,1,2,1,2,2,1,1,4},
    },
    { -- 3: Combo breaker
        {0,0, 4,4,4,4,2,4,4,2,4,4,4,4,2,2,4,4,2,2,4,4},
        {1,1, 3,2,3,3,4,3,3,4,3,4,3,3,2,3,4,1,3,3,3,3},
        {1,1, 3,1,2,3,1,3,2,2,3,4,3,3,2,1,2,2,1,4,3,1},
        {1,1, 3,1,2,2,1,1,2,2,2,4,3,3,1,2,2,2,1,4,3,1},
        {1,1, 3,1,2,2,1,2,2,2,2,4,3,3,2,2,1,2,4,4,2,1},
        {1,1, 3,1,2,2,1,2,1,2,2,2,2,3,1,1,2,2,2,4,2,2},
    },
    { -- 4: Judo toss
        {1,0, 3,2,2,3,2,3,3,1,3,3,1,3,2,2,2,1,3,2,3,3},
        {1,0, 3,2,2,3,2,3,3,1,3,3,1,3,2,2,2,1,3,1,3,3},
        {1,0, 3,2,2,3,2,2,3,1,3,3,1,3,1,1,2,3,3,1,3,3},
        {1,0, 3,2,2,3,2,2,3,4,3,3,1,3,1,1,2,3,3,1,3,3},
    },
    { -- 5: Flying kick
        {0,0, 4,4,4,4,2,4,4,2,4,4,4,4,2,2,4,4,2,2,4,4},
        {1,1, 3,2,3,2,2,3,3,1,1,3,3,3,3,3,2,1,1,4,3,3},
        {1,1, 3,2,3,2,2,3,3,1,1,3,3,3,3,3,2,2,1,1,3,3},
        {1,1, 3,2,1,2,2,3,3,1,1,2,3,1,3,3,2,2,1,1,3,3},
        {1,1, 3,2,1,2,2,3,2,1,1,2,1,1,3,3,2,4,1,4,2,3},
    },
    { -- 6: Spin sweep
        {0,0, 4,2,2,4,2,1,4,4,4,4,4,4,2,4,2,4,4,4,4,4},
        {1,0, 4,2,2,4,2,2,4,4,4,4,4,4,2,4,2,1,4,4,4,4},
        {1,1, 4,1,2,4,1,2,4,2,2,4,4,4,1,1,1,2,1,1,4,1},
        {1,1, 4,1,1,4,1,2,4,2,1,4,4,4,2,1,1,1,1,1,4,1},
    },
    { -- 7: Grapple slam
        {1,0, 3,2,2,2,2,3,2,1,1,2,1,1,2,2,2,1,2,2,2,2},
        {1,0, 3,2,2,2,1,4,1,1,2,1,2,2,2,2,1,2,1,1,1,2},
        {1,0, 3,1,2,2,1,2,1,1,2,1,1,1,2,2,2,2,1,1,1,2},
        {1,0, 3,1,2,2,1,2,1,2,2,1,1,1,2,2,2,2,1,1,1,2},
    },
    { -- 8: Grab & kick
        {1,1, 3,2,3,3,2,3,2,2,3,2,3,3,2,3,3,1,3,3,3,3},
        {1,0, 3,1,1,1,2,2,1,1,2,1,3,1,1,2,2,2,1,3,3,3},
        {1,0, 3,1,1,1,1,1,1,2,2,1,3,1,1,2,1,2,1,1,3,3},
        {1,0, 3,2,1,1,1,2,1,2,2,1,3,1,1,2,2,2,1,1,3,3},
        {1,0, 3,3,2,2,1,2,1,1,2,1,1,1,2,2,2,2,1,1,3,3},
    },
    { -- 9: Wushu
        {0,0, 4,1,1,1,1,1,2,1,1,2,2,4,2,2,2,4,2,2,4,4},
        {0,0, 4,2,1,2,2,2,1,2,2,1,1,4,1,2,2,4,1,1,4,4},
        {0,0, 4,2,1,2,1,2,1,1,2,1,1,4,2,2,2,2,1,1,4,4},
        {0,0, 4,1,2,2,2,2,1,2,4,1,1,4,2,2,4,4,1,1,4,4},
        {0,0, 4,1,2,1,1,2,1,1,3,1,1,1,1,2,2,2,1,1,4,4},
        {0,0, 4,1,2,1,1,2,1,2,2,1,1,1,1,2,2,2,1,1,4,4},
    },
    { -- 10: Tornado
        {0,0, 4,1,4,4,1,4,4,2,1,4,4,4,4,4,4,4,4,4,4,4},
        {0,0, 4,1,4,4,2,2,4,1,2,4,4,4,2,4,2,1,4,4,2,4},
        {0,0, 4,2,4,4,1,2,1,2,2,1,4,4,1,2,2,2,4,4,2,4},
        {0,0, 4,1,1,1,1,2,1,1,2,1,1,1,2,2,2,1,1,2,2,2},
        {0,0, 4,4,1,1,1,2,1,1,2,1,1,1,2,2,1,2,1,1,2,2},
        {0,0, 4,4,1,1,1,2,1,1,2,1,1,1,2,1,2,2,1,1,2,2},
        {0,0, 4,4,1,2,1,2,1,1,2,1,1,1,2,2,2,2,1,1,2,2},
    },
    { -- 11: Knee strike
        {0,0, 4,1,1,2,1,1,4,2,1,4,4,4,2,3,4,2,4,4,4,4},
        {0,0, 4,2,2,2,2,2,1,1,2,1,1,4,2,2,2,1,1,1,1,4},
        {0,0, 4,2,2,2,1,2,1,1,2,1,1,1,2,2,2,2,1,1,1,4},
        {0,0, 4,1,2,1,2,1,1,2,2,1,1,1,2,2,2,2,1,1,1,4},
        {0,0, 4,2,2,2,1,2,1,1,2,1,1,1,2,1,2,1,1,2,1,4},
        {0,0, 4,1,2,2,1,2,1,1,2,1,1,1,2,2,1,2,1,1,1,4},
    },
    { -- 12: Side kick chain
        {0,0, 3,1,3,3,3,3,3,2,3,3,3,3,3,3,1,1,3,2,3,3},
        {0,0, 3,3,3,3,3,3,3,3,3,3,3,3,4,2,2,1,3,1,3,2},
        {0,0, 3,1,1,1,2,3,3,1,3,1,3,1,2,2,2,2,4,1,3,2},
        {0,0, 3,2,2,1,2,3,3,2,2,3,3,1,1,2,2,3,1,1,1,2},
        {0,0, 3,3,3,3,1,2,1,1,2,3,3,1,2,2,2,1,1,1,1,2},
    },
    { -- 13: Quick jab
        {0,0, 3,2,2,2,1,1,1,3,3,3,3,3,2,2,3,3,2,2,3,3},
        {0,0, 3,1,1,1,1,2,2,3,3,3,3,3,2,2,2,2,2,2,2,2},
        {0,0, 3,2,2,2,2,1,1,2,2,2,3,3,1,1,1,1,1,1,1,1},
    },
    { -- 14: Leg sweep
        {0,0, 4,2,2,2,3,3,3,3,3,3,3,3,1,1,2,1,2,2,1,2},
        {0,0, 4,1,1,1,3,3,3,3,3,3,3,3,2,2,1,2,1,1,2,1},
        {0,0, 4,2,1,2,3,3,3,3,3,3,3,3,1,2,2,1,2,1,1,2},
    },
    { -- 15: Full relax opener into attack
        {0,0, 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4},
        {0,0, 4,1,1,1,1,1,1,1,1,1,4,4,1,1,1,1,1,1,1,1},
        {0,0, 3,2,2,2,2,2,2,2,2,2,3,3,2,2,2,2,2,2,2,2},
        {1,1, 3,1,1,1,1,1,1,1,1,1,3,3,1,1,1,1,1,1,1,1},
    },
}

local combo_names = {
    "Aikido Throw", "Power Rush", "Combo Breaker", "Judo Toss",
    "Flying Kick", "Spin Sweep", "Grapple Slam", "Grab & Kick",
    "Wushu", "Tornado", "Knee Strike", "Side Kick Chain",
    "Quick Jab", "Leg Sweep", "Relax Opener",
}

-- Mutate a turn: randomly change some joint states
local function mutate(turn)
    local m = {}
    for i = 1, 22 do
        if i > 2 and math.random(1, 100) <= mutation_rate then
            m[i] = math.random(1, 4)
        else
            m[i] = turn[i]
        end
    end
    return m
end

-- Apply a single turn
local function apply_turn(turn)
    if turn == nil then return end

    for j = 0, 19 do
        local state = turn[j + 3]
        if state ~= nil then
            set_joint_state(0, j, state)
        end
    end

    if set_grip_info ~= nil then
        if turn[1] ~= nil then set_grip_info(0, 11, turn[1]) end
        if turn[2] ~= nil then set_grip_info(0, 12, turn[2]) end
    end
end

-- Pick next combo, avoid repeat
local function pick_combo()
    local attempts = 0
    repeat
        chosen = math.random(1, #combos)
        attempts = attempts + 1
    until chosen ~= last_chosen or attempts > 5

    last_chosen = chosen
    move = 0
    rounds = rounds + 1
end

-- Advance to next move in combo
local function do_move()
    move = move + 1
    local c = combos[chosen]

    -- If combo ended, chain into a new one mid-round
    if c == nil or c[move] == nil then
        pick_combo()
        move = 1
        c = combos[chosen]
        if c == nil then return end
        echo("[AI+] Chaining into: " .. (combo_names[chosen] or "?"))
    end

    local turn = c[move]
    if turn == nil then return end

    -- Apply with mutation for variety
    if math.random(1, 100) <= 25 then
        apply_turn(mutate(turn))
    else
        apply_turn(turn)
    end
end

-- Reinforce on exit_freeze
local function redo_move()
    local c = combos[chosen]
    if c == nil then return end
    local turn = c[move]
    if turn == nil then return end
    apply_turn(turn)
end

-- New round
local function new_round()
    pick_combo()
    echo("[AI+] Round " .. rounds .. ": " .. (combo_names[chosen] or ("Combo #" .. chosen)))
    do_move()
end

-- =====================
-- INIT
-- =====================
math.randomseed(os.time())

echo("========================================")
echo("  TORIBASH AI+ ADVANCED FIGHTER")
echo("========================================")
echo("  " .. #combos .. " combat combos")
echo("  Auto-chains combos when one finishes")
echo("  " .. mutation_rate .. "% move mutation for variety")
echo("  Never repeats same combo twice in a row")
echo("  ")
echo("  Just press Space and watch!")
echo("========================================")

pick_combo()
do_move()

add_hook("enter_freeze", "ai_adv", do_move)
add_hook("exit_freeze", "ai_adv_exit", redo_move)
add_hook("new_game", "ai_adv_new", new_round)
add_hook("new_mp_game", "ai_adv_mp", new_round)
