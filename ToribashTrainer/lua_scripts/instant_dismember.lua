-- ============================================
-- Instant Dismember - Glass bodies
-- For Toribash offline/tutorial mode ONLY
-- ============================================
-- Load in-game: /ls instant_dismember

function instant_dismember_hook()
    run_cmd("set dismemberthreshold 1")
    run_cmd("set fracturethreshold 1")
    run_cmd("set tearthreshold 1")
    run_cmd("set dismemberment 1")
    run_cmd("set fracture 1")
    echo("Instant Dismember: everything shatters!")
end

add_hook("new_game", "instant_dismember", instant_dismember_hook)
echo("[Trainer] Instant Dismember loaded. One touch = destruction.")
