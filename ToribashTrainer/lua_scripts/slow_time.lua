-- ============================================
-- Slow Time - Extended turns for learning
-- For Toribash offline/tutorial mode ONLY
-- ============================================
-- Load in-game: /ls slow_time

function slow_time_hook()
    run_cmd("set turnframes 80")
    run_cmd("set matchframes 5000")
    echo("Slow Time: longer turns for practice!")
end

add_hook("new_game", "slow_time", slow_time_hook)
echo("[Trainer] Slow Time loaded. Take your time to learn.")
