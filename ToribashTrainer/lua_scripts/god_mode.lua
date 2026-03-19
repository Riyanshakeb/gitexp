-- ============================================
-- God Mode - Indestructible Tori
-- For Toribash offline/tutorial mode ONLY
-- ============================================
-- Load in-game: /ls god_mode

function god_mode_hook()
    run_cmd("set dismemberthreshold 999999")
    run_cmd("set fracturethreshold 999999")
    run_cmd("set tearthreshold 999999")
    echo("God Mode: You are indestructible!")
end

add_hook("new_game", "god_mode", god_mode_hook)
add_hook("enter_freeze", "god_mode_freeze", god_mode_hook)
echo("[Trainer] God Mode loaded.")
