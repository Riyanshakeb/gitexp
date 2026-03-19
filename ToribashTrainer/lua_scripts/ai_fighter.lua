-- ============================================
-- AI Memory Auto-Fighter for Toribash
-- For offline/tutorial mode ONLY
-- ============================================
-- Load in-game: /ls ai_fighter
--
-- LEARN MODE (first 10 rounds): Play normally.
--   The AI records your joint states each turn.
--
-- FIGHT MODE (after learning): The AI replays
--   your best moves automatically.
--
-- Memory persists in ai_memory.dat across sessions.

-- =====================
-- CONFIG
-- =====================
local LEARN_ROUNDS = 10
local MEMORY_FILE = "data/script/ai_memory.dat"
local NUM_JOINTS = 20
local PLAYER = 0  -- 0 = Tori (you), 1 = Uke (opponent)

-- =====================
-- STATE
-- =====================
local memory = {}            -- list of recorded round sequences
local current_round = {}     -- current round's turn snapshots
local turn_num = 0
local round_num = 0
local mode = "learn"

-- Pre-built combo library (proven fighting moves)
local COMBOS = {
    { -- Aikido throw
        { grip = {1,0}, joints = {3,2,3,3,2,3,3,1,3,3,3,3,2,2,3,3,3,3,3,3} },
        { grip = {1,0}, joints = {3,2,3,3,2,3,3,1,3,3,3,3,2,2,3,3,3,3,3,3} },
        { grip = {0,0}, joints = {3,2,3,3,2,3,3,1,3,3,3,3,2,2,3,3,3,3,3,3} },
        { grip = {0,0}, joints = {3,2,3,3,3,3,3,1,3,3,3,3,2,1,3,3,3,3,3,3} },
    },
    { -- Power kick
        { grip = {0,0}, joints = {4,1,1,1,1,1,2,1,1,2,2,4,2,2,2,4,2,2,4,4} },
        { grip = {0,0}, joints = {4,2,1,2,2,2,1,2,2,1,1,4,1,2,2,4,1,1,4,4} },
        { grip = {0,0}, joints = {4,2,1,2,1,2,1,1,2,1,1,4,2,2,2,2,1,1,4,4} },
        { grip = {0,0}, joints = {4,1,2,2,2,2,1,2,4,1,1,4,2,2,4,4,1,1,4,4} },
    },
    { -- Spin attack
        { grip = {0,0}, joints = {4,1,4,4,1,1,4,1,1,4,4,4,4,2,4,4,2,2,4,2} },
        { grip = {0,0}, joints = {4,2,1,4,2,2,4,1,1,4,4,4,4,1,2,4,1,1,4,2} },
        { grip = {0,0}, joints = {4,2,1,4,1,2,1,2,2,1,1,1,2,2,2,1,1,1,4,2} },
        { grip = {0,0}, joints = {4,2,1,1,1,2,1,2,2,1,1,1,2,2,1,2,1,1,4,2} },
    },
    { -- Judo flip
        { grip = {1,0}, joints = {3,2,2,2,2,3,2,1,1,2,1,1,2,2,2,1,2,2,2,2} },
        { grip = {1,0}, joints = {3,2,2,2,1,4,1,1,2,1,2,2,2,2,1,2,1,1,1,2} },
        { grip = {1,0}, joints = {3,1,2,2,1,2,1,1,2,1,1,1,2,2,2,2,1,1,1,2} },
        { grip = {1,0}, joints = {3,1,2,2,1,2,1,2,2,1,1,1,2,2,2,2,1,1,1,2} },
    },
    { -- Uppercut rush
        { grip = {0,0}, joints = {4,1,1,2,1,1,4,2,1,4,4,4,2,3,4,2,4,4,4,4} },
        { grip = {0,0}, joints = {4,2,2,2,2,2,1,1,2,1,1,4,2,2,2,1,1,1,1,4} },
        { grip = {0,0}, joints = {4,2,2,2,1,2,1,1,2,1,1,1,2,2,2,2,1,1,1,4} },
        { grip = {0,0}, joints = {4,1,2,1,2,1,1,2,2,1,1,1,2,2,2,2,1,1,1,4} },
    },
    { -- Grab and slam
        { grip = {1,1}, joints = {3,2,3,3,2,3,2,2,3,2,3,3,2,3,3,1,3,3,3,3} },
        { grip = {1,0}, joints = {3,1,1,1,2,2,1,1,2,1,3,1,1,2,2,2,1,3,3,3} },
        { grip = {1,0}, joints = {3,1,1,1,1,1,1,2,2,1,3,1,1,2,1,2,1,1,3,3} },
        { grip = {1,0}, joints = {3,2,1,1,1,2,1,2,2,1,3,1,1,2,2,2,1,1,3,3} },
        { grip = {1,0}, joints = {3,3,2,2,1,2,1,1,2,1,1,1,2,2,2,2,1,1,3,3} },
    },
}

-- =====================
-- READ JOINT STATES
-- =====================
function read_joints(player)
    local joints = {}
    for j = 0, NUM_JOINTS - 1 do
        local info = get_joint_info(player, j)
        if info then
            joints[j] = info.state or 3
        else
            joints[j] = 3  -- default to hold
        end
    end
    return joints
end

-- =====================
-- APPLY JOINTS
-- =====================
function apply_move(move_data)
    -- Set joints
    if move_data.joints then
        for j = 0, NUM_JOINTS - 1 do
            local state = move_data.joints[j + 1] or move_data.joints[j] or 3
            set_joint_state(PLAYER, j, state)
        end
    end
    -- Set grips
    if move_data.grip then
        if set_grip_info then
            set_grip_info(PLAYER, 11, move_data.grip[1] or 0)  -- right grip (joint 11)
            set_grip_info(PLAYER, 12, move_data.grip[2] or 0)  -- left grip (joint 12)
        end
    end
end

-- =====================
-- MEMORY FILE I/O
-- =====================
function save_memory()
    local f = io.open(MEMORY_FILE, "w")
    if not f then
        echo("[AI] Warning: could not save memory file")
        return
    end
    f:write("ROUNDS " .. #memory .. "\n")
    for r, round_data in ipairs(memory) do
        f:write("ROUND " .. #round_data .. "\n")
        for _, turn in ipairs(round_data) do
            local parts = {}
            for j = 0, NUM_JOINTS - 1 do
                parts[#parts + 1] = tostring(turn.joints[j] or 3)
            end
            local g1 = turn.grip and turn.grip[1] or 0
            local g2 = turn.grip and turn.grip[2] or 0
            f:write(g1 .. " " .. g2 .. " " .. table.concat(parts, " ") .. "\n")
        end
    end
    f:close()
end

function load_memory()
    local f = io.open(MEMORY_FILE, "r")
    if not f then return end

    memory = {}
    local current_round_data = nil
    local turns_remaining = 0

    for line in f:lines() do
        if line:match("^ROUNDS") then
            -- header, skip
        elseif line:match("^ROUND") then
            if current_round_data then
                memory[#memory + 1] = current_round_data
            end
            current_round_data = {}
            turns_remaining = tonumber(line:match("ROUND (%d+)")) or 0
        else
            -- Parse: grip1 grip2 j0 j1 j2 ... j19
            local nums = {}
            for n in line:gmatch("(%d+)") do
                nums[#nums + 1] = tonumber(n)
            end
            if #nums >= 22 then
                local turn = {
                    grip = { nums[1], nums[2] },
                    joints = {}
                }
                for j = 0, NUM_JOINTS - 1 do
                    turn.joints[j] = nums[j + 3]
                end
                if current_round_data then
                    current_round_data[#current_round_data + 1] = turn
                end
            end
        end
    end
    if current_round_data and #current_round_data > 0 then
        memory[#memory + 1] = current_round_data
    end

    f:close()
    echo("[AI] Loaded " .. #memory .. " round(s) from memory")
end

-- =====================
-- LEARN MODE
-- =====================
function learn_on_freeze()
    -- Read current joint states
    local joints = read_joints(PLAYER)
    local turn = {
        joints = joints,
        grip = { 0, 0 }  -- we can't easily read grip state, default
    }
    current_round[#current_round + 1] = turn
    turn_num = turn_num + 1
end

function learn_on_new_game()
    -- Save previous round if it had moves
    if #current_round > 0 then
        memory[#memory + 1] = current_round
        round_num = round_num + 1
        echo("[AI LEARN] Round " .. round_num .. "/" .. LEARN_ROUNDS ..
             " saved (" .. #current_round .. " turns)")
        save_memory()
    end

    current_round = {}
    turn_num = 0

    -- Check if we should switch to fight mode
    if round_num >= LEARN_ROUNDS then
        mode = "fight"
        echo("[AI] === SWITCHING TO FIGHT MODE ===")
        echo("[AI] " .. #memory .. " rounds learned. Now auto-fighting!")
        echo("[AI] The AI will use your recorded moves + built-in combos")
    end
end

-- =====================
-- FIGHT MODE
-- =====================
local active_sequence = nil
local active_turn = 0

function pick_sequence()
    -- 50% chance: use a learned sequence, 50%: use a built-in combo
    if #memory > 0 and math.random() < 0.6 then
        local idx = math.random(1, #memory)
        active_sequence = memory[idx]
        echo("[AI FIGHT] Using learned sequence #" .. idx)
    else
        local idx = math.random(1, #COMBOS)
        active_sequence = {}
        for _, m in ipairs(COMBOS[idx]) do
            local turn = { grip = m.grip, joints = {} }
            for j = 0, NUM_JOINTS - 1 do
                turn.joints[j] = m.joints[j + 1] or 3
            end
            active_sequence[#active_sequence + 1] = turn
        end
        echo("[AI FIGHT] Using built-in combo #" .. idx)
    end
    active_turn = 0
end

function fight_on_freeze()
    if not active_sequence then
        pick_sequence()
    end

    active_turn = active_turn + 1
    local turn_data = active_sequence[active_turn]

    if not turn_data then
        -- Loop back or pick new sequence
        active_turn = 1
        turn_data = active_sequence[active_turn]
    end

    if turn_data then
        apply_move(turn_data)
    end
end

function fight_on_new_game()
    pick_sequence()
end

-- =====================
-- MAIN HOOKS
-- =====================
function on_freeze()
    if mode == "learn" then
        learn_on_freeze()
    else
        fight_on_freeze()
    end
end

function on_new_game()
    if mode == "learn" then
        learn_on_new_game()
    else
        fight_on_new_game()
    end
end

-- =====================
-- INIT
-- =====================
math.randomseed(os.time())
load_memory()

if #memory >= LEARN_ROUNDS then
    mode = "fight"
    round_num = #memory
    echo("========================================")
    echo("  AI FIGHTER - FIGHT MODE")
    echo("========================================")
    echo("  " .. #memory .. " rounds in memory")
    echo("  + " .. #COMBOS .. " built-in combos")
    echo("  AI is auto-fighting now!")
    echo("========================================")
    pick_sequence()
else
    mode = "learn"
    round_num = #memory
    local remaining = LEARN_ROUNDS - round_num
    echo("========================================")
    echo("  AI FIGHTER - LEARN MODE")
    echo("========================================")
    echo("  Play " .. remaining .. " rounds normally")
    echo("  The AI records your joint moves")
    echo("  Then it fights using your style!")
    echo("========================================")
end

add_hook("enter_freeze", "ai_fighter", on_freeze)
add_hook("new_game", "ai_fighter", on_new_game)
