-- ============================================
-- Advanced AI Memory Fighter for Toribash
-- For offline/tutorial mode ONLY
-- ============================================
-- Load in-game: /ls ai_fighter_advanced
--
-- FEATURES:
--   - Records YOUR moves when you play manually
--   - Builds a "move dictionary" of joint combos
--   - Learns which moves deal the most damage
--   - Combines best partial moves (not just full replays)
--   - Adapts strategy based on opponent position
--   - Gets smarter with every round
--   - Persistent memory across game sessions

local MEMORY_FILE = "data/script/ai_advanced_memory.dat"
local LEARN_ROUNDS = 5
local MAX_COMBOS = 500

-- =====================
-- COMBO SYSTEM
-- =====================
-- Instead of recording full rounds, we record individual
-- joint configurations ("combos") with a damage score.
-- The AI mixes and matches the best combos each turn.

local combos = {}           -- {joints={}, score=0, uses=0}
local round_snapshots = {}
local current_turn = 0
local total_rounds = 0
local mode = "learn"
local wins = 0
local fight_style = "aggressive"  -- aggressive, defensive, balanced

-- Fight style parameters
local STYLES = {
    aggressive = {
        extend_bias = 0.6,    -- prefer extending joints
        target_zones = {4,5,6,7,8,9},  -- arms (pec, shoulder, elbow)
        description = "Aggressive - focuses on extending arms for attacks",
    },
    defensive = {
        contract_bias = 0.6,  -- prefer contracting joints
        target_zones = {12,13,14,15,16,17,18,19},  -- legs for stability
        description = "Defensive - contracts legs for stability",
    },
    balanced = {
        extend_bias = 0.3,
        contract_bias = 0.3,
        target_zones = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19},
        description = "Balanced - uses best moves from memory",
    },
    spin_kick = {
        -- Specific move pattern
        fixed = {
            [0]=3, [1]=1, [2]=2, [3]=1,       -- torso twist
            [4]=3, [5]=3, [6]=3, [7]=3, [8]=3, [9]=3,  -- arms hold
            [10]=3, [11]=3,                     -- grips hold
            [12]=1, [13]=1, [14]=2, [15]=1,    -- right leg: extend hip, contract knee
            [16]=2, [17]=2, [18]=1, [19]=2,    -- left leg: opposite
        },
        description = "Spin Kick - torso twist with leg extension",
    },
    uppercut = {
        fixed = {
            [0]=3, [1]=2, [2]=1, [3]=2,        -- crouch torso
            [4]=1, [5]=1, [6]=2, [7]=2, [8]=2, [9]=3,  -- right arm punch
            [10]=3, [11]=3,
            [12]=2, [13]=2, [14]=1, [15]=2,    -- legs push up
            [16]=2, [17]=2, [18]=1, [19]=2,
        },
        description = "Uppercut - crouch then extend right arm upward",
    },
}

-- =====================
-- MEMORY PERSISTENCE
-- =====================
function save_combos()
    local f = io.open(MEMORY_FILE, "w")
    if not f then return end

    f:write("HEADER\n")
    f:write("ROUNDS " .. total_rounds .. "\n")
    f:write("WINS " .. wins .. "\n")
    f:write("STYLE " .. fight_style .. "\n")
    f:write("COMBOS " .. #combos .. "\n\n")

    -- Save top combos sorted by score
    table.sort(combos, function(a, b) return a.score > b.score end)
    local save_count = math.min(#combos, MAX_COMBOS)

    for i = 1, save_count do
        local c = combos[i]
        local parts = {}
        for j = 0, 19 do
            table.insert(parts, tostring(c.joints[j] or 3))
        end
        f:write("C " .. c.score .. " " .. c.uses .. " " .. table.concat(parts, ",") .. "\n")
    end

    f:close()
end

function load_combos()
    local f = io.open(MEMORY_FILE, "r")
    if not f then return end

    combos = {}

    for line in f:lines() do
        if line:match("^ROUNDS") then
            total_rounds = tonumber(line:match("ROUNDS (%d+)")) or 0
        elseif line:match("^WINS") then
            wins = tonumber(line:match("WINS (%d+)")) or 0
        elseif line:match("^STYLE") then
            fight_style = line:match("STYLE (%S+)") or "balanced"
        elseif line:match("^C ") then
            local score_str, uses_str, vals = line:match("C (%S+) (%S+) (.+)")
            if vals then
                local joints = {}
                local j = 0
                for v in vals:gmatch("(%d+)") do
                    joints[j] = tonumber(v)
                    j = j + 1
                end
                table.insert(combos, {
                    joints = joints,
                    score = tonumber(score_str) or 0,
                    uses = tonumber(uses_str) or 0,
                })
            end
        end
    end

    f:close()
    echo("[AI+] Loaded " .. #combos .. " combos from memory")
end

-- =====================
-- SNAPSHOT & SCORING
-- =====================
function capture_snapshot()
    local snap = { joints = {} }
    local info = get_world_state()

    if info and info.players and info.players[0] then
        local p = info.players[0]
        if p.joints then
            for j = 0, 19 do
                if p.joints[j] then
                    snap.joints[j] = p.joints[j].state or 3
                else
                    snap.joints[j] = 3
                end
            end
        else
            for j = 0, 19 do snap.joints[j] = 3 end
        end
    else
        for j = 0, 19 do snap.joints[j] = 3 end
    end

    return snap
end

function get_damage_score()
    local info = get_world_state()
    if not info or not info.players then return 0 end

    local score = 0
    local p0 = info.players[0]
    local p1 = info.players[1]

    if p1 and p1.injury then
        score = score + p1.injury * 10
    end
    if p0 and p0.injury then
        score = score - p0.injury * 3
    end

    return score
end

-- =====================
-- LEARNING
-- =====================
function learn_freeze()
    local snap = capture_snapshot()
    table.insert(round_snapshots, snap)
    current_turn = current_turn + 1
end

function learn_end_round()
    local score = get_damage_score()
    local is_win = false
    if get_winner and get_winner() == 0 then
        is_win = true
        wins = wins + 1
        score = score + 500
    end

    -- Store each turn's joints as a combo with proportional score
    for i, snap in ipairs(round_snapshots) do
        local turn_score = score / math.max(#round_snapshots, 1)
        -- Later turns in winning rounds get bonus (finishing moves)
        if is_win and i > #round_snapshots * 0.7 then
            turn_score = turn_score * 2
        end

        table.insert(combos, {
            joints = snap.joints,
            score = turn_score,
            uses = 0,
        })
    end

    total_rounds = total_rounds + 1
    echo("[AI+ LEARN] Round " .. total_rounds .. "/" .. LEARN_ROUNDS ..
         " | Score: " .. math.floor(score) ..
         (is_win and " WIN!" or ""))

    -- Trim combos
    if #combos > MAX_COMBOS then
        table.sort(combos, function(a, b) return a.score > b.score end)
        while #combos > MAX_COMBOS do
            table.remove(combos)
        end
    end

    save_combos()

    -- Switch mode check
    if total_rounds >= LEARN_ROUNDS and #combos >= 5 then
        mode = "fight"
        -- Auto-select best style based on what worked
        auto_select_style()
        echo("[AI+] *** FIGHT MODE ACTIVATED ***")
        echo("[AI+] Style: " .. fight_style .. " | " .. #combos .. " combos learned")
    end

    round_snapshots = {}
    current_turn = 0
end

-- =====================
-- FIGHTING
-- =====================
function build_smart_move()
    local move = {}

    -- Start with a base from best combos
    if #combos > 0 then
        table.sort(combos, function(a, b) return a.score > b.score end)

        -- Pick from top performers with weighted randomness
        local pool_size = math.min(10, #combos)
        local base_idx = weighted_random(pool_size)
        local base = combos[base_idx]

        for j = 0, 19 do
            move[j] = base.joints[j] or 3
        end
        base.uses = base.uses + 1

        -- Mix in mutations from other good combos for variety
        if math.random() < 0.3 and #combos > 1 then
            local mix_idx = math.random(1, math.min(5, #combos))
            local mix = combos[mix_idx]
            -- Replace 2-4 random joints from the other combo
            local num_mix = math.random(2, 4)
            for _ = 1, num_mix do
                local j = math.random(0, 19)
                move[j] = mix.joints[j] or move[j]
            end
        end
    else
        -- No combos yet, use style-based defaults
        move = generate_style_move()
    end

    -- Apply style-specific overrides
    local style = STYLES[fight_style]
    if style and style.fixed then
        -- Use the fixed pattern with small mutations
        for j = 0, 19 do
            if math.random() < 0.8 then
                move[j] = style.fixed[j] or move[j]
            end
        end
    end

    return move
end

function generate_style_move()
    local move = {}
    local style = STYLES[fight_style] or STYLES["balanced"]

    if style.fixed then
        for j = 0, 19 do
            move[j] = style.fixed[j] or 3
        end
    else
        for j = 0, 19 do
            local r = math.random()
            if style.extend_bias and r < style.extend_bias then
                move[j] = 1  -- extend
            elseif style.contract_bias and r < (style.extend_bias or 0) + (style.contract_bias or 0) then
                move[j] = 2  -- contract
            elseif r < 0.85 then
                move[j] = 3  -- hold
            else
                move[j] = 4  -- relax
            end
        end
    end

    return move
end

function weighted_random(pool_size)
    -- Higher weight to top-scoring combos
    local total_weight = 0
    local weights = {}
    for i = 1, pool_size do
        local w = pool_size - i + 1  -- top combo gets highest weight
        weights[i] = w
        total_weight = total_weight + w
    end

    local r = math.random() * total_weight
    local cumulative = 0
    for i = 1, pool_size do
        cumulative = cumulative + weights[i]
        if r <= cumulative then
            return i
        end
    end
    return 1
end

function fight_freeze()
    local move = build_smart_move()

    -- Apply joints
    for j = 0, 19 do
        set_joint_state(0, j, move[j] or 3)
    end

    -- Record for continued learning
    local snap = capture_snapshot()
    table.insert(round_snapshots, snap)
    current_turn = current_turn + 1

    if current_turn <= 2 then
        echo("[AI+ FIGHT] Turn " .. current_turn .. " | Style: " .. fight_style)
    end
end

function fight_end_round()
    local score = get_damage_score()
    local is_win = false
    if get_winner and get_winner() == 0 then
        is_win = true
        wins = wins + 1
        score = score + 500
    end

    -- Continue learning from fight rounds
    for i, snap in ipairs(round_snapshots) do
        local turn_score = score / math.max(#round_snapshots, 1)
        if is_win and i > #round_snapshots * 0.7 then
            turn_score = turn_score * 2
        end
        table.insert(combos, {
            joints = snap.joints,
            score = turn_score,
            uses = 0,
        })
    end

    total_rounds = total_rounds + 1

    if #combos > MAX_COMBOS then
        table.sort(combos, function(a, b) return a.score > b.score end)
        while #combos > MAX_COMBOS do
            table.remove(combos)
        end
    end

    save_combos()

    -- Adapt style every 5 rounds
    if total_rounds % 5 == 0 then
        auto_select_style()
    end

    local w_pct = 0
    if total_rounds > 0 then
        w_pct = math.floor((wins / total_rounds) * 100)
    end

    echo("[AI+ FIGHT] Round " .. total_rounds ..
         " | Score: " .. math.floor(score) ..
         (is_win and " WIN!" or "") ..
         " | W/R: " .. wins .. "/" .. total_rounds .. " (" .. w_pct .. "%)" ..
         " | Style: " .. fight_style)

    round_snapshots = {}
    current_turn = 0
end

-- =====================
-- ADAPTIVE STYLE
-- =====================
function auto_select_style()
    if #combos < 5 then
        fight_style = "balanced"
        return
    end

    -- Analyze what types of moves score highest
    table.sort(combos, function(a, b) return a.score > b.score end)

    local extend_score = 0
    local contract_score = 0
    local check_count = math.min(20, #combos)

    for i = 1, check_count do
        local c = combos[i]
        for j = 0, 19 do
            if c.joints[j] == 1 then
                extend_score = extend_score + c.score
            elseif c.joints[j] == 2 then
                contract_score = contract_score + c.score
            end
        end
    end

    if extend_score > contract_score * 1.5 then
        fight_style = "aggressive"
    elseif contract_score > extend_score * 1.5 then
        fight_style = "defensive"
    else
        -- Pick a special move style randomly for variety
        local specials = {"balanced", "spin_kick", "uppercut"}
        fight_style = specials[math.random(1, #specials)]
    end
end

-- =====================
-- HOOKS
-- =====================
function on_new_game()
    round_snapshots = {}
    current_turn = 0
end

function on_freeze()
    if mode == "learn" then
        learn_freeze()
    else
        fight_freeze()
    end
end

function on_end_game()
    if mode == "learn" then
        learn_end_round()
    else
        fight_end_round()
    end
end

-- =====================
-- INITIALIZATION
-- =====================
math.randomseed(os.time())
load_combos()

if #combos >= LEARN_ROUNDS * 3 then
    mode = "fight"
    auto_select_style()
    echo("========================================")
    echo("  AI+ ADVANCED FIGHTER - FIGHT MODE")
    echo("========================================")
    echo("  Memory: " .. #combos .. " combos")
    echo("  Wins: " .. wins .. "/" .. total_rounds)
    echo("  Style: " .. fight_style)
    echo("  AI will auto-fight and keep learning!")
    echo("========================================")
else
    mode = "learn"
    local remaining = LEARN_ROUNDS - math.floor(#combos / 3)
    if remaining < 1 then remaining = 1 end
    echo("========================================")
    echo("  AI+ ADVANCED FIGHTER - LEARN MODE")
    echo("========================================")
    echo("  Play " .. remaining .. " more rounds to teach the AI")
    echo("  The AI watches and memorizes your moves")
    echo("  Then it fights on its own!")
    echo("========================================")
end

add_hook("new_game", "ai_adv_new", on_new_game)
add_hook("enter_freeze", "ai_adv_freeze", on_freeze)
add_hook("end_game", "ai_adv_end", on_end_game)
