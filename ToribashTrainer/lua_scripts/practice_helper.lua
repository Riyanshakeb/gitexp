-- ============================================
-- Practice Helper - All-in-one Tutorial Trainer
-- For Toribash offline/tutorial mode ONLY
-- ============================================
-- Load in-game: /ls practice_helper
--
-- Features:
--   - God Mode (can't be dismembered)
--   - Slow turns for careful moves
--   - Light gravity for easier control
--   - Large arena
--   - Opponent auto-relaxes (easy wins)

function practice_setup()
    run_cmd("set dismemberthreshold 999999")
    run_cmd("set fracturethreshold 999999")
    run_cmd("set tearthreshold 999999")
    run_cmd("set turnframes 60")
    run_cmd("set matchframes 3000")
    run_cmd("set gravity 0 -5.0 0")
    run_cmd("set dojosize 1200")
    echo("Practice Helper active!")
    echo("  God Mode ON | Slow turns | Light gravity | Big arena")
end

function relax_opponent()
    for j = 0, 19 do
        set_joint_state(1, j, 4)
    end
end

add_hook("new_game", "practice_setup_hook", practice_setup)
add_hook("enter_freeze", "practice_relax", relax_opponent)
echo("[Trainer] Practice Helper loaded!")
