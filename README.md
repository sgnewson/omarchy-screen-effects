# Screen effects

Omarchy bar plugin for Hyprland overlay shaders — snow, fireworks, aurora,
flowers, and friends. One effect at a time; pick the active one again to turn
it off.

```bash
omarchy plugin add https://github.com/sgnewson/omarchy-screen-effects.git --enable
```

That places a wand icon on the right of the bar, next to bluetooth and the
other status widgets. Left click opens the picker. Right or middle click turns
the overlay off.

## How it works

The widget runs `hypr-screen-effect` from this folder. State lives in
`~/.config/hypr/shaders/current`; the compiled shader is `stack.frag`. A copy
of any part in `~/.config/hypr/shaders/parts/` overrides the bundled GLSL.

Hyprland reloads reset `decoration.screen_shader` unless look-and-feel
reapplies it. Keep this in `~/.config/hypr/looknfeel.lua`:

```lua
local shader_dir = os.getenv("HOME") .. "/.config/hypr/shaders"
local screen_shader = ""
local damage_tracking = 2
local vfr = true
do
  local f = io.open(shader_dir .. "/current", "r")
  local effect = "off"
  if f then
    effect = (f:read("*l") or effect):match("^%s*(.-)%s*$") or effect
    f:close()
  end
  if effect ~= "" and effect ~= "off" then
    screen_shader = shader_dir .. "/stack.frag"
    damage_tracking = 0
    vfr = false
  end
end

hl.config({
  decoration = { screen_shader = screen_shader },
  debug = { damage_tracking = damage_tracking, vfr = vfr },
})
```
