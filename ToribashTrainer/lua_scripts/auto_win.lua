-- ============================================
-- Auto Win - Opponent collapses
-- For Toribash offline/tutorial mode ONLY
-- ============================================
-- Load in-game: /ls auto_win

function auto_win_hook()
    for j = 0, 19 do
        set_joint_state(1, j, 4)
    end
    echo("Opponent joints relaxed - easy win!")
end

add_hook("new_game", "auto_win", auto_win_hook)
add_hook("enter_freeze", "auto_win_freeze", auto_win_hook)
echo("[Trainer] Auto Win loaded. Opponent collapses each round.")
