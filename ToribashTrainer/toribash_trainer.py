"""
Toribash Offline Tutorial Trainer
==================================
A trainer tool for Toribash's offline/tutorial single-player mode.
Modifies game rules, physics, and provides Lua helper scripts.

Features:
  - God Mode (near-impossible dismemberment)
  - Custom gravity
  - One-hit dismember
  - Infinite match time
  - Auto-win scripts
  - Custom mod generator
  - Backup & restore original settings

Usage:
  python toribash_trainer.py

Requirements:
  - Python 3.8+
  - Toribash installed (Steam or standalone)
  - Windows OS (for game path detection)
"""

import os
import sys
import json
import shutil
import tkinter as tk
from tkinter import ttk, messagebox, filedialog
from pathlib import Path
from datetime import datetime


DEFAULT_RULES = {
    "matchframes": 500,
    "turnframes": 10,
    "gravity": "0 -9.82 0",
    "engagedistance": 100,
    "engageheight": 0,
    "engagerotation": 0,
    "dojosize": 880,
    "dojotype": 0,
    "dismemberthreshold": 100,
    "fracturethreshold": 0,
    "tearthreshold": 0,
    "winpoint": 0,
    "dqtimeout": 0,
    "dismemberment": 1,
    "fracture": 1,
    "grip": 1,
    "sumo": 0,
    "damage": 1,
}

PRESET_PROFILES = {
    "God Mode": {
        "dismemberthreshold": 999999,
        "fracturethreshold": 999999,
        "tearthreshold": 999999,
        "description": "Near-impossible to dismember you. Your Tori becomes nearly indestructible.",
    },
    "Glass Cannon": {
        "dismemberthreshold": 1,
        "fracturethreshold": 1,
        "tearthreshold": 1,
        "description": "Everything shatters on contact. One touch = dismemberment.",
    },
    "Moon Gravity": {
        "gravity": "0 -1.62 0",
        "description": "Low gravity like on the moon. Floaty fights!",
    },
    "Zero Gravity": {
        "gravity": "0 0 0",
        "description": "No gravity at all. Float freely in space.",
    },
    "Jupiter Gravity": {
        "gravity": "0 -24.79 0",
        "description": "Extreme gravity. Everything slams down hard.",
    },
    "Slow Motion": {
        "matchframes": 2000,
        "turnframes": 50,
        "description": "Extended turns for precise control. Great for learning.",
    },
    "Infinite Time": {
        "matchframes": 99999,
        "turnframes": 100,
        "description": "Nearly infinite match time. Take as long as you need.",
    },
    "Tiny Arena": {
        "dojosize": 200,
        "description": "Very small arena. Forced close combat.",
    },
    "Huge Arena": {
        "dojosize": 5000,
        "description": "Massive arena. Lots of room to maneuver.",
    },
    "Sumo Mode": {
        "sumo": 1,
        "dojosize": 500,
        "dismemberment": 0,
        "description": "Push opponent off the ring to win. No dismemberment.",
    },
    "Tutorial Easy": {
        "dismemberthreshold": 999999,
        "fracturethreshold": 999999,
        "matchframes": 2000,
        "turnframes": 50,
        "gravity": "0 -5.0 0",
        "description": "Perfect for learning. You can't be dismembered, slow turns, light gravity.",
    },
}


class ToribashTrainer:
    def __init__(self, root):
        self.root = root
        self.root.title("Toribash Offline Trainer")
        self.root.geometry("820x720")
        self.root.configure(bg="#1a1a2e")
        self.root.resizable(True, True)

        self.game_path = tk.StringVar(value=self.detect_game_path())
        self.current_rules = dict(DEFAULT_RULES)
        self.backup_exists = False

        self.style = ttk.Style()
        self.configure_styles()
        self.build_ui()

    def configure_styles(self):
        self.style.theme_use("clam")
        self.style.configure("Title.TLabel", background="#1a1a2e", foreground="#e94560",
                             font=("Segoe UI", 18, "bold"))
        self.style.configure("Sub.TLabel", background="#1a1a2e", foreground="#aaaacc",
                             font=("Segoe UI", 10))
        self.style.configure("Section.TLabel", background="#16213e", foreground="#e94560",
                             font=("Segoe UI", 12, "bold"))
        self.style.configure("Dark.TFrame", background="#1a1a2e")
        self.style.configure("Card.TFrame", background="#16213e")
        self.style.configure("Accent.TButton", background="#e94560", foreground="white",
                             font=("Segoe UI", 10, "bold"), padding=8)
        self.style.map("Accent.TButton", background=[("active", "#c81e45")])
        self.style.configure("Normal.TButton", background="#16213e", foreground="white",
                             font=("Segoe UI", 9), padding=6)
        self.style.map("Normal.TButton", background=[("active", "#0f3460")])
        self.style.configure("Dark.TLabel", background="#16213e", foreground="#ddddee",
                             font=("Segoe UI", 10))
        self.style.configure("Value.TLabel", background="#16213e", foreground="#e94560",
                             font=("Segoe UI", 10, "bold"))
        self.style.configure("Dark.TLabelframe", background="#16213e", foreground="#e94560")
        self.style.configure("Dark.TLabelframe.Label", background="#16213e", foreground="#e94560",
                             font=("Segoe UI", 11, "bold"))

    def detect_game_path(self):
        common_paths = [
            r"C:\Program Files (x86)\Steam\steamapps\common\Toribash",
            r"C:\Program Files\Steam\steamapps\common\Toribash",
            r"C:\Program Files (x86)\Toribash",
            r"C:\Program Files\Toribash",
            os.path.expanduser(r"~\AppData\Local\Toribash"),
            os.path.expanduser("~/Library/Application Support/Steam/steamapps/common/Toribash"),
            os.path.expanduser("~/.steam/steam/steamapps/common/Toribash"),
            os.path.expanduser("~/.local/share/Steam/steamapps/common/Toribash"),
        ]
        for p in common_paths:
            if os.path.isdir(p):
                return p
        return ""

    def build_ui(self):
        main = ttk.Frame(self.root, style="Dark.TFrame")
        main.pack(fill=tk.BOTH, expand=True, padx=12, pady=12)

        ttk.Label(main, text="⚔ Toribash Offline Trainer", style="Title.TLabel").pack(pady=(0, 2))
        ttk.Label(main, text="Tutorial / Single-Player Mode Only", style="Sub.TLabel").pack(pady=(0, 12))

        path_frame = ttk.Frame(main, style="Card.TFrame")
        path_frame.pack(fill=tk.X, pady=(0, 10))
        ttk.Label(path_frame, text="Game Path:", style="Dark.TLabel").pack(side=tk.LEFT, padx=8, pady=8)
        path_entry = ttk.Entry(path_frame, textvariable=self.game_path, width=50)
        path_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=4, pady=8)
        ttk.Button(path_frame, text="Browse", style="Normal.TButton",
                   command=self.browse_path).pack(side=tk.LEFT, padx=8, pady=8)

        notebook = ttk.Notebook(main)
        notebook.pack(fill=tk.BOTH, expand=True, pady=(0, 10))

        self.build_presets_tab(notebook)
        self.build_custom_tab(notebook)
        self.build_lua_tab(notebook)

        btn_bar = ttk.Frame(main, style="Dark.TFrame")
        btn_bar.pack(fill=tk.X)
        ttk.Button(btn_bar, text="Apply to Game", style="Accent.TButton",
                   command=self.apply_mod).pack(side=tk.LEFT, padx=4)
        ttk.Button(btn_bar, text="Backup Originals", style="Normal.TButton",
                   command=self.backup_originals).pack(side=tk.LEFT, padx=4)
        ttk.Button(btn_bar, text="Restore Originals", style="Normal.TButton",
                   command=self.restore_originals).pack(side=tk.LEFT, padx=4)
        ttk.Button(btn_bar, text="Install Lua Scripts", style="Normal.TButton",
                   command=self.install_lua_scripts).pack(side=tk.LEFT, padx=4)
        ttk.Button(btn_bar, text="Export Mod File", style="Normal.TButton",
                   command=self.export_mod).pack(side=tk.RIGHT, padx=4)

        self.status_var = tk.StringVar(value="Ready. Set your Toribash game path above.")
        status = ttk.Label(main, textvariable=self.status_var, style="Sub.TLabel")
        status.pack(fill=tk.X, pady=(8, 0))

    def build_presets_tab(self, notebook):
        frame = ttk.Frame(notebook, style="Card.TFrame")
        notebook.add(frame, text=" ⚡ Quick Presets ")

        canvas = tk.Canvas(frame, bg="#16213e", highlightthickness=0)
        scrollbar = ttk.Scrollbar(frame, orient=tk.VERTICAL, command=canvas.yview)
        scroll_frame = ttk.Frame(canvas, style="Card.TFrame")

        scroll_frame.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        canvas.create_window((0, 0), window=scroll_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)

        canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        for name, preset in PRESET_PROFILES.items():
            card = ttk.Frame(scroll_frame, style="Card.TFrame")
            card.pack(fill=tk.X, padx=10, pady=5)

            info = ttk.Frame(card, style="Card.TFrame")
            info.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=10, pady=8)
            ttk.Label(info, text=name, style="Value.TLabel").pack(anchor="w")
            ttk.Label(info, text=preset["description"], style="Dark.TLabel",
                      wraplength=500).pack(anchor="w")

            ttk.Button(card, text="Apply", style="Accent.TButton",
                       command=lambda n=name: self.apply_preset(n)).pack(side=tk.RIGHT, padx=10, pady=8)

    def build_custom_tab(self, notebook):
        frame = ttk.Frame(notebook, style="Card.TFrame")
        notebook.add(frame, text=" 🔧 Custom Rules ")

        canvas = tk.Canvas(frame, bg="#16213e", highlightthickness=0)
        scrollbar = ttk.Scrollbar(frame, orient=tk.VERTICAL, command=canvas.yview)
        scroll_frame = ttk.Frame(canvas, style="Card.TFrame")

        scroll_frame.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        canvas.create_window((0, 0), window=scroll_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)

        canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        self.rule_vars = {}
        descriptions = {
            "matchframes": "Total match frames (higher = longer match)",
            "turnframes": "Frames per turn (higher = more time per move)",
            "gravity": "Gravity vector (format: X Y Z, default: 0 -9.82 0)",
            "engagedistance": "Starting distance between players",
            "engageheight": "Starting height above ground",
            "engagerotation": "Starting rotation angle",
            "dojosize": "Arena size (200=tiny, 880=normal, 5000=huge)",
            "dojotype": "Arena shape (0=square, 1=circle)",
            "dismemberthreshold": "Force to dismember (1=easy, 999999=impossible)",
            "fracturethreshold": "Force to fracture (0=disabled)",
            "tearthreshold": "Force to break grip (0=disabled)",
            "winpoint": "Points to win (0=disabled)",
            "dqtimeout": "DQ timeout frames (0=disabled)",
            "dismemberment": "Enable dismemberment (0/1)",
            "fracture": "Enable fracture (0/1)",
            "grip": "Enable grip (0/1)",
            "sumo": "Enable sumo mode (0/1)",
            "damage": "Enable damage (0/1)",
        }

        for key, value in DEFAULT_RULES.items():
            row = ttk.Frame(scroll_frame, style="Card.TFrame")
            row.pack(fill=tk.X, padx=10, pady=3)

            ttk.Label(row, text=key, style="Value.TLabel", width=22).pack(side=tk.LEFT, padx=(8, 4))
            var = tk.StringVar(value=str(value))
            self.rule_vars[key] = var
            ttk.Entry(row, textvariable=var, width=20).pack(side=tk.LEFT, padx=4)
            ttk.Label(row, text=descriptions.get(key, ""), style="Dark.TLabel").pack(
                side=tk.LEFT, padx=8)

    def build_lua_tab(self, notebook):
        frame = ttk.Frame(notebook, style="Card.TFrame")
        notebook.add(frame, text=" 📜 Lua Scripts ")

        info = ttk.Label(frame, text="Lua scripts are installed to your Toribash /data/script/ folder.\n"
                         "Load them in-game with /ls <scriptname> (without .lua extension).",
                         style="Dark.TLabel", wraplength=700)
        info.pack(padx=10, pady=10, anchor="w")

        scripts = [
            ("ai_fighter.lua",
             "AI MEMORY FIGHTER — Learns your moves for 10 rounds, then auto-fights using best combos.",
             self.get_auto_win_script),
            ("ai_fighter_advanced.lua",
             "ADVANCED AI — Combo dictionary, adaptive styles (aggressive/defensive/spin kick/uppercut), persistent memory.",
             self.get_auto_win_script),
            ("auto_win.lua",
             "Automatically sets all opponent joints to relaxed state, making them collapse.",
             self.get_auto_win_script),
            ("god_mode.lua",
             "Sets dismember/fracture thresholds to maximum at the start of each match.",
             self.get_god_mode_script),
            ("slow_time.lua",
             "Increases turnframes and matchframes for slow-motion tutorial practice.",
             self.get_slow_time_script),
            ("custom_gravity.lua",
             "Cycle through gravity presets with in-game hotkey. Moon, zero-G, Jupiter, and more.",
             self.get_custom_gravity_script),
            ("instant_dismember.lua",
             "Sets dismemberment threshold to 1 — everything shatters on contact.",
             self.get_instant_dismember_script),
            ("practice_helper.lua",
             "All-in-one tutorial helper: extended time, low gravity, invincible Tori.",
             self.get_practice_helper_script),
        ]

        for name, desc, _ in scripts:
            card = ttk.Frame(frame, style="Card.TFrame")
            card.pack(fill=tk.X, padx=10, pady=4)

            info_f = ttk.Frame(card, style="Card.TFrame")
            info_f.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=10, pady=6)
            ttk.Label(info_f, text=name, style="Value.TLabel").pack(anchor="w")
            ttk.Label(info_f, text=desc, style="Dark.TLabel", wraplength=500).pack(anchor="w")

    def browse_path(self):
        path = filedialog.askdirectory(title="Select Toribash Installation Folder")
        if path:
            self.game_path.set(path)
            self.status_var.set(f"Game path set: {path}")

    def apply_preset(self, name):
        preset = PRESET_PROFILES[name]
        for key, value in DEFAULT_RULES.items():
            self.rule_vars[key].set(str(value))
        for key, value in preset.items():
            if key != "description" and key in self.rule_vars:
                self.rule_vars[key].set(str(value))
        self.status_var.set(f"Preset '{name}' loaded. Click 'Apply to Game' to write to disk.")
        self.current_rules = {k: self.rule_vars[k].get() for k in DEFAULT_RULES}

    def get_mod_content(self):
        lines = []
        lines.append("# Toribash Trainer Mod")
        lines.append(f"# Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        lines.append("")
        for key in DEFAULT_RULES:
            val = self.rule_vars[key].get()
            lines.append(f"set {key} {val}")
        lines.append("")
        return "\n".join(lines)

    def validate_path(self):
        path = self.game_path.get()
        if not path or not os.path.isdir(path):
            messagebox.showerror("Error", "Invalid Toribash game path. Please set the correct path.")
            return None
        return Path(path)

    def apply_mod(self):
        game = self.validate_path()
        if not game:
            return

        data_dir = game / "data"
        if not data_dir.exists():
            data_dir.mkdir(parents=True, exist_ok=True)

        mod_dir = data_dir / "mod"
        if not mod_dir.exists():
            mod_dir.mkdir(parents=True, exist_ok=True)

        mod_file = mod_dir / "trainer_mod.tbm"
        content = self.get_mod_content()
        mod_file.write_text(content)

        script_dir = data_dir / "script"
        if not script_dir.exists():
            script_dir.mkdir(parents=True, exist_ok=True)

        autoexec = script_dir / "autoexec.lua"
        lua_content = self.generate_autoexec_lua()
        autoexec.write_text(lua_content)

        self.status_var.set(f"Mod applied! Mod file written to {mod_file}")
        messagebox.showinfo("Success",
                            f"Trainer mod applied!\n\n"
                            f"Mod: {mod_file}\n"
                            f"Script: {autoexec}\n\n"
                            f"In Toribash, press Ctrl+M and select 'trainer_mod' to load,\n"
                            f"or type: /set mod trainer_mod")

    def generate_autoexec_lua(self):
        lines = [
            '-- Toribash Trainer Autoexec Script',
            f'-- Generated: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}',
            '',
            'function trainer_apply()',
        ]
        for key in DEFAULT_RULES:
            val = self.rule_vars[key].get()
            lines.append(f'    run_cmd("set {key} {val}")')
        lines.extend([
            '    echo("Trainer settings applied!")',
            'end',
            '',
            'add_hook("enter_freeze", "trainer_hook", trainer_apply)',
            'echo("Toribash Trainer loaded. Settings will auto-apply each round.")',
        ])
        return "\n".join(lines)

    def backup_originals(self):
        game = self.validate_path()
        if not game:
            return

        backup_dir = game / "trainer_backup"
        backup_dir.mkdir(exist_ok=True)

        backed_up = []
        for sub in ["data/mod", "data/script"]:
            src = game / sub
            if src.exists():
                dst = backup_dir / sub
                dst.mkdir(parents=True, exist_ok=True)
                for f in src.iterdir():
                    if f.is_file():
                        shutil.copy2(f, dst / f.name)
                        backed_up.append(f.name)

        self.backup_exists = True
        self.status_var.set(f"Backup created at {backup_dir} ({len(backed_up)} files)")
        messagebox.showinfo("Backup Complete", f"Backed up {len(backed_up)} files to:\n{backup_dir}")

    def restore_originals(self):
        game = self.validate_path()
        if not game:
            return

        backup_dir = game / "trainer_backup"
        if not backup_dir.exists():
            messagebox.showwarning("No Backup", "No backup found. Create a backup first.")
            return

        restored = 0
        for sub in ["data/mod", "data/script"]:
            src = backup_dir / sub
            if src.exists():
                dst = game / sub
                dst.mkdir(parents=True, exist_ok=True)
                for f in src.iterdir():
                    if f.is_file():
                        shutil.copy2(f, dst / f.name)
                        restored += 1

        trainer_mod = game / "data" / "mod" / "trainer_mod.tbm"
        if trainer_mod.exists():
            trainer_mod.unlink()

        trainer_scripts = ["autoexec.lua", "auto_win.lua", "god_mode.lua",
                           "slow_time.lua", "custom_gravity.lua",
                           "instant_dismember.lua", "practice_helper.lua"]
        for s in trainer_scripts:
            sf = game / "data" / "script" / s
            if sf.exists():
                sf.unlink()

        self.status_var.set(f"Restored {restored} original files. Trainer mods removed.")
        messagebox.showinfo("Restored", "Original game files restored. Trainer mods removed.")

    def install_lua_scripts(self):
        game = self.validate_path()
        if not game:
            return

        script_dir = game / "data" / "script"
        script_dir.mkdir(parents=True, exist_ok=True)

        scripts = {
            "auto_win.lua": self.get_auto_win_script(),
            "god_mode.lua": self.get_god_mode_script(),
            "slow_time.lua": self.get_slow_time_script(),
            "custom_gravity.lua": self.get_custom_gravity_script(),
            "instant_dismember.lua": self.get_instant_dismember_script(),
            "practice_helper.lua": self.get_practice_helper_script(),
        }
        ai_scripts_dir = Path(__file__).parent / "lua_scripts"
        for ai_script in ["ai_fighter.lua", "ai_fighter_advanced.lua"]:
            ai_path = ai_scripts_dir / ai_script
            if ai_path.exists():
                scripts[ai_script] = ai_path.read_text()

        for name, content in scripts.items():
            (script_dir / name).write_text(content)

        self.status_var.set(f"Installed {len(scripts)} Lua scripts to {script_dir}")
        messagebox.showinfo("Scripts Installed",
                            f"Installed {len(scripts)} scripts to:\n{script_dir}\n\n"
                            f"In-game, use /ls <name> to load.\n"
                            f"Example: /ls practice_helper")

    def export_mod(self):
        path = filedialog.asksaveasfilename(
            title="Export Toribash Mod",
            defaultextension=".tbm",
            filetypes=[("Toribash Mod", "*.tbm"), ("All files", "*.*")]
        )
        if path:
            content = self.get_mod_content()
            with open(path, "w") as f:
                f.write(content)
            self.status_var.set(f"Mod exported to {path}")

    def get_auto_win_script(self):
        return '''-- Auto Win Script for Toribash Tutorial/Offline
-- Relaxes all opponent joints so they collapse

local JOINTS = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19}

function auto_win_hook()
    for _, j in ipairs(JOINTS) do
        set_joint_state(1, j, 4)  -- player index 1 = opponent (Uke), state 4 = relax
    end
    echo("Auto-win: opponent joints relaxed")
end

add_hook("new_game", "auto_win", auto_win_hook)
add_hook("enter_freeze", "auto_win_freeze", auto_win_hook)
echo("Auto Win loaded. Opponent will collapse each round.")
'''

    def get_god_mode_script(self):
        return '''-- God Mode Script for Toribash Tutorial/Offline
-- Makes your Tori nearly indestructible

function god_mode_hook()
    run_cmd("set dismemberthreshold 999999")
    run_cmd("set fracturethreshold 999999")
    run_cmd("set tearthreshold 999999")
    echo("God Mode active - you are indestructible!")
end

add_hook("new_game", "god_mode", god_mode_hook)
add_hook("enter_freeze", "god_mode_freeze", god_mode_hook)
echo("God Mode loaded. You cannot be dismembered.")
'''

    def get_slow_time_script(self):
        return '''-- Slow Time Script for Toribash Tutorial/Offline
-- Extended turns for careful practice

function slow_time_hook()
    run_cmd("set turnframes 80")
    run_cmd("set matchframes 5000")
    echo("Slow Time active - take your time!")
end

add_hook("new_game", "slow_time", slow_time_hook)
echo("Slow Time loaded. Longer turns and match duration.")
'''

    def get_custom_gravity_script(self):
        return '''-- Custom Gravity Cycler for Toribash Tutorial/Offline
-- Cycles through gravity presets each round

local presets = {
    { name = "Normal",  grav = "0 -9.82 0" },
    { name = "Moon",    grav = "0 -1.62 0" },
    { name = "Zero-G",  grav = "0 0 0" },
    { name = "Jupiter", grav = "0 -24.79 0" },
    { name = "Light",   grav = "0 -5.0 0" },
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
echo("Gravity Cycler loaded. Gravity changes each round.")
echo("Current presets: Normal > Moon > Zero-G > Jupiter > Light > Upside Down")
'''

    def get_instant_dismember_script(self):
        return '''-- Instant Dismember Script for Toribash Tutorial/Offline
-- Everything shatters on minimal contact

function instant_dismember_hook()
    run_cmd("set dismemberthreshold 1")
    run_cmd("set fracturethreshold 1")
    run_cmd("set tearthreshold 1")
    run_cmd("set dismemberment 1")
    run_cmd("set fracture 1")
    echo("Instant Dismember active - everything shatters!")
end

add_hook("new_game", "instant_dismember", instant_dismember_hook)
echo("Instant Dismember loaded. One touch = destruction.")
'''

    def get_practice_helper_script(self):
        return '''-- Practice Helper - All-in-one Tutorial Trainer
-- Combines: God mode + slow time + light gravity

function practice_setup()
    -- God mode
    run_cmd("set dismemberthreshold 999999")
    run_cmd("set fracturethreshold 999999")
    run_cmd("set tearthreshold 999999")
    -- Slow time
    run_cmd("set turnframes 60")
    run_cmd("set matchframes 3000")
    -- Light gravity
    run_cmd("set gravity 0 -5.0 0")
    -- Big arena
    run_cmd("set dojosize 1200")
    echo("Practice Helper active!")
    echo("  - God Mode ON")
    echo("  - Slow turns (60 frames)")
    echo("  - Light gravity")
    echo("  - Large arena")
end

function relax_opponent()
    for j = 0, 19 do
        set_joint_state(1, j, 4)
    end
end

add_hook("new_game", "practice_setup_hook", practice_setup)
add_hook("enter_freeze", "practice_relax", relax_opponent)
echo("Practice Helper loaded. Perfect for learning!")
echo("Load in-game with: /ls practice_helper")
'''


def main():
    root = tk.Tk()
    app = ToribashTrainer(root)
    root.mainloop()


if __name__ == "__main__":
    main()
