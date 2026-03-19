-- ============================================
-- AI Memory Auto-Fighter for Toribash
-- For offline/tutorial mode ONLY
-- ============================================
-- Load in-game: /ls ai_fighter
--
-- How it works:
--   LEARN MODE (first 10 rounds): Play normally. The AI records
--   every joint state you set each turn along with the damage you deal.
--   Winning rounds get saved to memory.
--
--   FIGHT MODE (after 10 rounds): The AI picks the best-scoring
--   move sequence from memory and auto-applies your joints.
--   It keeps learning from new rounds too.
--
-- Commands (type in chat):
--   /ls ai_fighter         - Load the script
--   The script auto-switches from learn to fight mode.

-- =====================
-- CONFIGURATION
-- =====================
local LEARN_ROUNDS = 10
local MEMORY_FILE = "data/script/ai_memory.dat"
local MAX_MEMORY = 200

-- Joint names for display
local JOINT_NAMES = {
    [0]  = "neck",
    [1]  = "chest",
    [2]  = "lumbar",
    [3]  = "abs",
    [4]  = "r_pec",
    [5]  = "r_shoulder",
    [6]  = "r_elbow",
    [7]  = "l_pec",
    [8]  = "l_shoulder",
    [9]  = "l_elbow",
    [10] = "r_grip",
    [11] = "l_grip",
    [12] = "r_glute",
    [13] = "r_hip",
    [14] = "r_knee",
    [15] = "r_ankle",
    [16] = "l_glute",
    [17] = "l_hip",
    [18] = "l_knee",
    [19] = "l_ankle",
}

-- Joint states
local STATE_NAMES = {
    [1] = "extend",
    [2] = "contract",
    [3] = "hold",
    [4] = "relax",
}

-- =====================
-- MEMORY SYSTEM
-- =====================
local memory = {}
local current_round = 0
local current_round_moves = {}
local current_turn = 0
local mode = "learn"
local total_rounds_played = 0
local wins = 0

function save_memory()
    local f = io.open(MEMORY_FILE, "w")
    if not f then return end

    f:write("-- AI Fighter Memory\n")
    f:write("-- Total entries: " .. #memory .. "\n")
    f:write("-- Wins: " .. wins .. " / " .. total_rounds_played .. "\n\n")

    for i, entry in ipairs(memory) do
        f:write("ENTRY " .. i .. "\n")
        f:write("SCORE " .. entry.score .. "\n")
        f:write("TURNS " .. #entry.turns .. "\n")
        for t, turn_data in ipairs(entry.turns) do
            local parts = {}
            for j = 0, 19 do
                table.insert(parts, tostring(turn_data[j] or 3))
            end
            f:write("T " .. table.concat(parts, ",") .. "\n")
        end
        f:write("END\n\n")
    end

    f:close()
end

function load_memory()
    local f = io.open(MEMORY_FILE, "r")
    if not f then return end

    memory = {}
    local current_entry = nil

    for line in f:lines() do
        if line:match("^ENTRY") then
            current_entry = { score = 0, turns = {} }
        elseif line:match("^SCORE") then
            if current_entry then
                current_entry.score = tonumber(line:match("SCORE (%S+)")) or 0
            end
        elseif line:match("^T ") then
            if current_entry then
                local turn_data = {}
                local vals = line:match("T (.+)")
                local j = 0
                for v in vals:gmatch("(%d+)") do
                    turn_data[j] = tonumber(v)
                    j = j + 1
                end
                table.insert(current_entry.turns, turn_data)
            end
        elseif line:match("^END") then
            if current_entry then
                table.insert(memory, current_entry)
                current_entry = nil
            end
        end
    end

    f:close()
    echo("[AI] Loaded " .. #memory .. " move sequences from memory")
end

-- =====================
-- SCORING
-- =====================
function calculate_round_score()
    local info = get_world_state()
    if not info then return 0 end

    local score = 0

    local p0 = info.players[0]
    local p1 = info.players[1]

    if p0 and p1 then
        -- Score based on damage dealt to opponent
        if p1.injury then
            score = score + p1.injury * 10
        end
        -- Bonus for not taking damage
        if p0.injury then
            score = score - p0.injury * 5
        end
    end

    -- Big bonus for winning
    if get_winner and get_winner() == 0 then
        score = score + 1000
        wins = wins + 1
    end

    return math.max(score, 0)
end

-- =====================
-- RECORDING (LEARN MODE)
-- =====================
function record_turn()
    local turn_data = {}
    local info = get_world_state()

    if info and info.players and info.players[0] then
        local joints = info.players[0].joints
        if joints then
            for j = 0, 19 do
                if joints[j] then
                    turn_data[j] = joints[j].state or 3
                else
                    turn_data[j] = 3
                end
            end
        else
            for j = 0, 19 do
                turn_data[j] = 3
            end
        end
    else
        for j = 0, 19 do
            turn_data[j] = 3
        end
    end

    table.insert(current_round_moves, turn_data)
    current_turn = current_turn + 1
end

function on_round_end_learn()
    local score = calculate_round_score()
    total_rounds_played = total_rounds_played + 1

    if #current_round_moves > 0 then
        table.insert(memory, {
            score = score,
            turns = current_round_moves,
        })
        echo("[AI] Round " .. total_rounds_played .. " recorded | Score: " .. math.floor(score))
    end

    -- Trim memory to keep only best entries
    if #memory > MAX_MEMORY then
        table.sort(memory, function(a, b) return a.score > b.score end)
        while #memory > MAX_MEMORY do
            table.remove(memory)
        end
    end

    save_memory()

    -- Check if we should switch to fight mode
    if total_rounds_played >= LEARN_ROUNDS and #memory >= 3 then
        mode = "fight"
        echo("[AI] *** SWITCHING TO FIGHT MODE ***")
        echo("[AI] " .. #memory .. " sequences learned. Now auto-fighting!")
    end

    current_round_moves = {}
    current_turn = 0
end

-- =====================
-- PLAYBACK (FIGHT MODE)
-- =====================
function get_best_sequence()
    if #memory == 0 then return nil end

    -- Sort by score descending
    table.sort(memory, function(a, b) return a.score > b.score end)

    -- Pick from top 5 with some randomness for variety
    local pool_size = math.min(5, #memory)
    local pick = math.random(1, pool_size)
    return memory[pick]
end

function apply_turn_from_memory()
    local best = get_best_sequence()
    if not best then
        echo("[AI] No moves in memory yet. Playing randomly.")
        apply_random_turn()
        record_turn()
        return
    end

    local turn_idx = current_turn + 1
    local turn_data = best.turns[turn_idx]

    if not turn_data then
        -- If we've run out of recorded turns, loop from start
        turn_idx = ((current_turn) % #best.turns) + 1
        turn_data = best.turns[turn_idx]
    end

    if turn_data then
        for j = 0, 19 do
            local state = turn_data[j] or 3
            set_joint_state(0, j, state)
        end
    end

    -- Also record what we're doing for further learning
    record_turn()
    current_turn = current_turn + 1

    if current_turn <= 3 then
        local seq_score = math.floor(best.score)
        echo("[AI] Auto-fighting (sequence score: " .. seq_score .. ")")
    end
end

function apply_random_turn()
    local states = {1, 2, 3, 4}
    for j = 0, 19 do
        local s = states[math.random(1, 4)]
        set_joint_state(0, j, s)
    end
end

function on_round_end_fight()
    local score = calculate_round_score()
    total_rounds_played = total_rounds_played + 1

    -- Save this round too if it scored well
    if #current_round_moves > 0 then
        table.insert(memory, {
            score = score,
            turns = current_round_moves,
        })

        if #memory > MAX_MEMORY then
            table.sort(memory, function(a, b) return a.score > b.score end)
            while #memory > MAX_MEMORY do
                table.remove(memory)
            end
        end

        save_memory()
    end

    local w_pct = 0
    if total_rounds_played > 0 then
        w_pct = math.floor((wins / total_rounds_played) * 100)
    end
    echo("[AI] Round " .. total_rounds_played .. " | Score: " .. math.floor(score) ..
         " | Memory: " .. #memory .. " | Wins: " .. wins .. " (" .. w_pct .. "%)")

    current_round_moves = {}
    current_turn = 0
end

-- =====================
-- HOOKS
-- =====================
function on_new_game()
    current_round_moves = {}
    current_turn = 0
end

function on_freeze()
    if mode == "learn" then
        record_turn()
    else
        apply_turn_from_memory()
    end
end

function on_end_game()
    if mode == "learn" then
        on_round_end_learn()
    else
        on_round_end_fight()
    end
end

-- =====================
-- INITIALIZATION
-- =====================
math.randomseed(os.time())
load_memory()

-- If we have enough memory from previous sessions, start in fight mode
if #memory >= LEARN_ROUNDS then
    mode = "fight"
    echo("[AI Fighter] Loaded with " .. #memory .. " memorized sequences")
    echo("[AI Fighter] Starting in FIGHT MODE (auto-play)")
else
    echo("[AI Fighter] Starting in LEARN MODE")
    echo("[AI Fighter] Play " .. (LEARN_ROUNDS - #memory) .. " more rounds to teach the AI")
end
echo("[AI Fighter] Memory file: " .. MEMORY_FILE)

add_hook("new_game", "ai_new", on_new_game)
add_hook("enter_freeze", "ai_freeze", on_freeze)
add_hook("end_game", "ai_end", on_end_game)
