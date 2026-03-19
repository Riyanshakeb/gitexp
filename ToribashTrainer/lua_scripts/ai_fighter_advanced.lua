-- ============================================
-- Advanced AI Auto-Fighter for Toribash
-- For offline/tutorial mode ONLY
-- ============================================
-- Load in-game: /ls ai_fighter_advanced
--
-- This version uses proven fighting combos and
-- randomized mutations to create varied attacks.
-- No learning phase needed — fights immediately!
--
-- Features:
--   - 15 built-in combat combos (aikido, kicks, throws, etc.)
--   - Random combo selection each round
--   - Joint mutation for move variety
--   - Grip management
--   - Works instantly — no learning required

local PLAYER = 0  -- 0 = Tori (you)
local NUM_JOINTS = 20

-- =====================
-- COMBAT COMBO LIBRARY
-- Each combo is a sequence of turns.
-- joints = {neck, chest, lumbar, abs, r_pec, r_shoulder, r_elbow,
--           l_pec, l_shoulder, l_elbow, r_grip, l_grip,
--           r_glute, r_hip, r_knee, r_ankle, l_glute, l_hip, l_knee, l_ankle}
-- States: 1=extend, 2=contract, 3=hold, 4=relax
-- =====================

local COMBOS = {
    { name = "Aikido Throw",
        {grip={1,0}, joints={3,2,3,3,2,3,3,1,3,3,3,3,2,2,3,3,3,3,3,3}},
        {grip={1,0}, joints={3,2,3,3,2,3,3,1,3,3,3,3,2,2,3,3,3,3,3,3}},
        {grip={0,0}, joints={3,2,3,3,2,3,3,1,3,3,3,3,2,2,3,3,3,3,3,3}},
        {grip={0,0}, joints={3,2,3,3,3,3,3,1,3,3,3,3,2,1,3,3,3,3,3,3}},
        {grip={0,0}, joints={3,2,3,3,3,3,3,1,3,3,3,3,2,3,3,3,3,3,3,3}},
    },
    { name = "Power Rush",
        {grip={0,1}, joints={1,1,1,2,1,3,2,2,4,4,1,4,2,2,1,2,2,3,2,2}},
        {grip={0,1}, joints={1,1,1,3,1,3,2,2,2,1,1,1,2,2,1,2,1,3,2,2}},
        {grip={0,1}, joints={1,4,2,1,4,1,1,4,2,1,1,1,1,2,1,2,2,1,1,4}},
    },
    { name = "Combo Breaker",
        {grip={0,0}, joints={4,4,4,4,2,4,4,2,4,4,4,4,2,2,4,4,2,2,4,4}},
        {grip={1,1}, joints={3,2,3,3,4,3,3,4,3,4,3,3,2,3,4,1,3,3,3,3}},
        {grip={1,1}, joints={3,1,2,3,1,3,2,2,3,4,3,3,2,1,2,2,1,4,3,1}},
        {grip={1,1}, joints={3,1,2,2,1,1,2,2,2,4,3,3,1,2,2,2,1,4,3,1}},
        {grip={1,1}, joints={3,1,2,2,1,2,2,2,2,4,3,3,2,2,1,2,4,4,2,1}},
        {grip={1,1}, joints={3,1,2,2,1,2,1,2,2,2,2,3,1,1,2,2,2,4,2,2}},
    },
    { name = "Judo Hip Toss",
        {grip={1,0}, joints={3,2,2,3,2,3,3,1,3,3,1,3,2,2,2,1,3,2,3,3}},
        {grip={1,0}, joints={3,2,2,3,2,3,3,1,3,3,1,3,2,2,2,1,3,1,3,3}},
        {grip={1,0}, joints={3,2,2,3,2,2,3,1,3,3,1,3,1,1,2,3,3,1,3,3}},
        {grip={1,0}, joints={3,2,2,3,2,2,3,4,3,3,1,3,1,1,2,3,3,1,3,3}},
    },
    { name = "Flying Kick",
        {grip={0,0}, joints={4,4,4,4,2,4,4,2,4,4,4,4,2,2,4,4,2,2,4,4}},
        {grip={1,1}, joints={3,2,3,3,4,3,3,4,3,3,3,3,3,3,4,1,4,3,3,3}},
        {grip={1,1}, joints={3,2,3,2,2,3,3,1,1,3,3,3,3,3,2,1,1,4,3,3}},
        {grip={1,1}, joints={3,2,3,2,2,3,3,1,1,3,3,3,3,3,2,2,1,1,3,3}},
        {grip={1,1}, joints={3,2,1,2,2,3,3,1,1,2,3,1,3,3,2,2,1,1,3,3}},
        {grip={1,1}, joints={3,2,1,2,2,3,3,1,1,2,3,1,3,3,2,2,1,1,3,3}},
        {grip={1,1}, joints={3,2,1,2,2,3,2,1,1,2,1,1,3,3,2,4,1,4,2,3}},
    },
    { name = "Spin Sweep",
        {grip={0,0}, joints={4,2,2,4,2,1,4,4,4,4,4,4,2,4,2,4,4,4,4,4}},
        {grip={1,0}, joints={4,2,2,4,2,2,4,4,4,4,4,4,2,4,2,1,4,4,4,4}},
        {grip={1,1}, joints={4,1,2,4,1,2,4,2,2,4,4,4,1,1,1,2,1,1,4,1}},
        {grip={1,1}, joints={4,1,2,4,1,2,4,2,2,4,4,4,1,1,1,2,1,1,4,1}},
        {grip={1,1}, joints={4,1,1,4,1,2,4,2,1,4,4,4,2,1,1,1,1,1,4,1}},
    },
    { name = "Grapple Slam",
        {grip={1,0}, joints={3,2,2,2,2,3,2,1,1,2,1,1,2,2,2,1,2,2,2,2}},
        {grip={1,0}, joints={3,2,2,2,1,4,1,1,2,1,2,2,2,2,1,2,1,1,1,2}},
        {grip={1,0}, joints={3,1,2,2,1,2,1,1,2,1,1,1,2,2,2,2,1,1,1,2}},
        {grip={1,0}, joints={3,1,2,2,1,2,1,2,2,1,1,1,2,2,2,2,1,1,1,2}},
    },
    { name = "Double Grab",
        {grip={1,1}, joints={3,3,3,3,2,3,1,2,3,1,1,1,2,3,3,3,3,3,3,3}},
        {grip={1,1}, joints={3,3,3,3,2,2,1,2,2,1,1,1,2,3,3,3,3,3,3,3}},
        {grip={1,1}, joints={3,3,3,3,2,2,1,2,2,1,1,1,2,3,2,2,3,3,3,3}},
    },
    { name = "Grab & Kick",
        {grip={1,1}, joints={3,2,3,3,2,3,2,2,3,2,3,3,2,3,3,1,3,3,3,3}},
        {grip={1,0}, joints={3,1,1,1,2,2,1,1,2,1,3,1,1,2,2,2,1,3,3,3}},
        {grip={1,0}, joints={3,1,1,1,1,1,1,2,2,1,3,1,1,2,1,2,1,1,3,3}},
        {grip={1,0}, joints={3,2,1,1,1,2,1,2,2,1,3,1,1,2,2,2,1,1,3,3}},
        {grip={1,0}, joints={3,3,2,2,1,2,1,1,2,1,1,1,2,2,2,2,1,1,3,3}},
    },
    { name = "Side Kick",
        {grip={0,0}, joints={3,1,3,3,3,3,3,2,3,3,3,3,3,3,1,1,3,2,3,3}},
        {grip={0,0}, joints={3,3,3,3,3,3,3,3,3,3,3,3,4,2,2,1,3,1,3,2}},
        {grip={0,0}, joints={3,1,1,1,2,3,3,1,3,1,3,1,2,2,2,2,4,1,3,2}},
        {grip={0,0}, joints={3,2,2,1,2,3,3,2,2,3,3,1,1,2,2,3,1,1,1,2}},
        {grip={0,0}, joints={3,3,3,3,1,2,1,1,2,3,3,1,2,2,2,1,1,1,1,2}},
    },
    { name = "Wushu Strike",
        {grip={0,0}, joints={4,1,1,1,1,1,2,1,1,2,2,4,2,2,2,4,2,2,4,4}},
        {grip={0,0}, joints={4,2,1,2,2,2,1,2,2,1,1,4,1,2,2,4,1,1,4,4}},
        {grip={0,0}, joints={4,2,1,2,1,2,1,1,2,1,1,4,2,2,2,2,1,1,4,4}},
        {grip={0,0}, joints={4,1,2,2,2,2,1,2,4,1,1,4,2,2,4,4,1,1,4,4}},
        {grip={0,0}, joints={4,1,2,1,1,2,1,1,3,1,1,1,1,2,2,2,1,1,4,4}},
    },
    { name = "Tornado",
        {grip={0,0}, joints={4,1,4,4,1,4,4,2,1,4,4,4,4,4,4,4,4,4,4,4}},
        {grip={0,0}, joints={4,1,4,4,2,2,4,1,2,4,4,4,2,4,2,1,4,4,2,4}},
        {grip={0,0}, joints={4,2,4,4,1,2,1,2,2,1,4,4,1,2,2,2,4,4,2,4}},
        {grip={0,0}, joints={4,1,1,1,1,2,1,1,2,1,1,1,2,2,2,1,1,2,2,2}},
        {grip={0,0}, joints={4,4,1,1,1,2,1,1,2,1,1,1,2,2,1,2,1,1,2,2}},
    },
    { name = "Knee Strike",
        {grip={0,0}, joints={4,1,1,2,1,1,4,2,1,4,4,4,2,3,4,2,4,4,4,4}},
        {grip={0,0}, joints={4,2,2,2,2,2,1,1,2,1,1,4,2,2,2,1,1,1,1,4}},
        {grip={0,0}, joints={4,2,2,2,1,2,1,1,2,1,1,1,2,2,2,2,1,1,1,4}},
        {grip={0,0}, joints={4,1,2,1,2,1,1,2,2,1,1,1,2,2,2,2,1,1,1,4}},
        {grip={0,0}, joints={4,2,2,2,1,2,1,1,2,1,1,1,2,1,2,1,1,2,1,4}},
    },
    { name = "Quick Jab",
        {grip={0,0}, joints={3,2,2,2,1,1,1,3,3,3,3,3,2,2,3,3,2,2,3,3}},
        {grip={0,0}, joints={3,1,1,1,1,2,2,3,3,3,3,3,2,2,2,2,2,2,2,2}},
        {grip={0,0}, joints={3,2,2,2,2,1,1,2,2,2,3,3,1,1,1,1,1,1,1,1}},
    },
    { name = "Leg Sweep",
        {grip={0,0}, joints={4,2,2,2,3,3,3,3,3,3,3,3,1,1,2,1,2,2,1,2}},
        {grip={0,0}, joints={4,1,1,1,3,3,3,3,3,3,3,3,2,2,1,2,1,1,2,1}},
        {grip={0,0}, joints={4,2,1,2,3,3,3,3,3,3,3,3,1,2,2,1,2,1,1,2}},
    },
}

-- =====================
-- STATE
-- =====================
local active_combo = nil
local active_combo_name = ""
local turn_in_combo = 0
local rounds_fought = 0

-- =====================
-- APPLY A MOVE
-- =====================
function apply_move(move_data)
    for j = 0, NUM_JOINTS - 1 do
        local state = move_data.joints[j + 1] or 3
        set_joint_state(PLAYER, j, state)
    end
    if move_data.grip and set_grip_info then
        set_grip_info(PLAYER, 11, move_data.grip[1] or 0)
        set_grip_info(PLAYER, 12, move_data.grip[2] or 0)
    end
end

-- =====================
-- MUTATE A MOVE (for variety)
-- =====================
function mutate_move(move_data)
    local mutated = { joints = {}, grip = move_data.grip }
    for j = 1, NUM_JOINTS do
        if math.random() < 0.15 then
            -- 15% chance to randomize each joint
            mutated.joints[j] = math.random(1, 4)
        else
            mutated.joints[j] = move_data.joints[j]
        end
    end
    return mutated
end

-- =====================
-- PICK A COMBO
-- =====================
function pick_combo()
    local idx = math.random(1, #COMBOS)
    active_combo = COMBOS[idx]
    active_combo_name = active_combo.name or ("Combo #" .. idx)
    turn_in_combo = 0
    rounds_fought = rounds_fought + 1
    echo("[AI+] Round " .. rounds_fought .. ": " .. active_combo_name)
end

-- =====================
-- HOOKS
-- =====================
function on_freeze()
    if not active_combo then
        pick_combo()
    end

    turn_in_combo = turn_in_combo + 1

    -- Get the move for this turn (loop if needed)
    local move_idx = turn_in_combo
    local combo_len = #active_combo
    if move_idx > combo_len then
        move_idx = ((turn_in_combo - 1) % combo_len) + 1
    end

    local move_data = active_combo[move_idx]
    if move_data and move_data.joints then
        -- Apply with occasional mutation for unpredictability
        if math.random() < 0.2 then
            apply_move(mutate_move(move_data))
        else
            apply_move(move_data)
        end
    end
end

function on_new_game()
    pick_combo()
end

-- =====================
-- INIT
-- =====================
math.randomseed(os.time())

echo("========================================")
echo("  AI+ ADVANCED AUTO-FIGHTER")
echo("========================================")
echo("  " .. #COMBOS .. " combat combos loaded")
echo("  Styles: Aikido, Judo, Wushu, Kicks,")
echo("  Throws, Sweeps, Grabs, and more!")
echo("  ")
echo("  AI fights automatically every round")
echo("  with randomized move selection")
echo("========================================")

pick_combo()

add_hook("enter_freeze", "ai_adv_fighter", on_freeze)
add_hook("new_game", "ai_adv_fighter", on_new_game)
