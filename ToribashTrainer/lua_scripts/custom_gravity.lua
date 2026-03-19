-- ============================================
-- Gravity Cycler - Change gravity each round
-- For Toribash offline/tutorial mode ONLY
-- ============================================
-- Load in-game: /ls custom_gravity

local presets = {
    { name = "Normal",      grav = "0 -9.82 0" },
    { name = "Moon",        grav = "0 -1.62 0" },
    { name = "Zero-G",      grav = "0 0 0" },
    { name = "Jupiter",     grav = "0 -24.79 0" },
    { name = "Light",       grav = "0 -5.0 0" },
    { name = "Upside Down", grav = "0 9.82 0" },
}
local current = 1

function cycle_gravity()
    local p = presets[current]
    run_cmd("set gravity " .. p.grav)
    echo("Gravity: " .. p.name .. " (" .. p.grav .. ")")
    current = current + 1
    if current > #presets then current = 1 end
end

add_hook("new_game", "gravity_cycler", cycle_gravity)
echo("[Trainer] Gravity Cycler loaded. Changes each round:")
echo("  Normal > Moon > Zero-G > Jupiter > Light > Upside Down")
