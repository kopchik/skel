#!/usr/bin/env python3
#TODO: check config before restart
from libqtile.config import Key, Screen, Group, Drag, Click
from libqtile.command import lazy
from libqtile import layout, bar, widget, hook

TERM_CMD = 'urxvtcd -rv -fade 50' \
           ' -fn "xft:Terminus:size=16"' \
           ' -fb "xft:Terminus:bold:size=16"' \
           ' -sl 10000 -si -tn xterm'
SCREEN_BRIGHTNESS = "sudo value.py --set /sys/class/backlight/intel_backlight/brightness --min=10 --max /sys/class/backlight/intel_backlight/max_brightness -- %s"
mod = "mod4"
win = "mod4"
alt = "mod1"
shift = "shift"
MouseL = "Button1"
MouseM = "Button2"
MouseR = "Button3"

keys = [
    # LAYOUT
    Key([], 'Caps_Lock', lazy.spawn("setxkbmap -layout us")),
    Key([shift], 'Caps_Lock', lazy.spawn("setxkbmap -layout ru")),

    # FOCUS
    Key([alt], 'Tab', lazy.group.next_window(), lazy.window.bring_to_front()),

    # LAUNCH PROGRAMS
    Key([win], "x", lazy.spawn(TERM_CMD)),
    Key([win], "d", lazy.spawn("dmenu_run -fn -*-*-*-*-*-*-24-*-*-*-*-*-*-*")),

    # BRIGHTNESS AND BACKLIT
    Key([win], "Up",   lazy.spawn(SCREEN_BRIGHTNESS % '+10%')),
    Key([win], "Down", lazy.spawn(SCREEN_BRIGHTNESS % '-10%')),

    Key([win, shift], "Up",   lazy.spawn("sudo asus-kbd-backlight up")),
    Key([alt, shift], "Down", lazy.spawn("sudo asus-kbd-backlight down")),

    # MISC
    Key([mod], "w", lazy.window.kill()),
    Key([win], "r", lazy.restart()),
    Key([mod, "control"], "q", lazy.shutdown()),
    Key([mod], "m", lazy.window.toggle_maximize()),
    Key([win], "l", lazy.spawn("sflock")),
    Key( [win], "f", lazy.window.toggle_fullscreen()),

    # RESIZE
    Key([alt, shift], "Up", lazy.window.resize_floating(0, -10, 0,0)),
    Key([alt, shift], "Down", lazy.window.resize_floating(0, 30, 0,0)),
    Key([alt, shift], "Left", lazy.window.resize_floating(-10, 0, 0,0)),
    Key([alt, shift], "Right", lazy.window.resize_floating(20, 0, 0,0)),

    # MOVE
    Key([alt], "Up", lazy.window.move_floating(0, -20, 0,0)),
    Key([alt], "Down", lazy.window.move_floating(0, 20, 0,0)),
    Key([alt], "Left", lazy.window.move_floating(-20, 0, 0,0)),
    Key([alt], "Right", lazy.window.move_floating(20, 0, 0,0)),

    # VIRTUAL DESKTOPS
    Key([win], "Right", lazy.screen.next_group()),
    Key([win], "Left",  lazy.screen.prev_group()),

]

groups = [Group(i) for i in "123456789"]
for i in groups:
    # mod1 + letter of group = switch to group
    keys.append( Key([mod], i.name, lazy.group[i.name].toscreen()))

    # mod1 + shift + letter of group = switch to & move focused window to group
    keys.append( Key([mod, "shift"], i.name, lazy.window.togroup(i.name)))

layouts = [
    layout.Floating(),
    #layout.Max(),
    #layout.Stack(num_stacks=2)
]

widget_defaults = dict(
    font='Arial',
    fontsize=24,
    padding=3,
)

screens = [
    Screen(
        bottom=bar.Bar(
            [
                widget.GroupBox(),
                widget.Prompt(),
                #widget.WindowName(),
                widget.TaskList(),
                widget.NetGraph(frequency=2),
                widget.CPUGraph(frequency=2),
                #widget.TextBox("default config", name="default"),
                widget.Systray(),
                widget.DF(visible_on_warn=False, background="003000", format="{uf:.1f}G"),
                widget.Clock(format='%Y-%m-%d %a %H:%M'),
                #widget.Notify(),
                widget.Battery(update_delay=3.),
                #widget.ThermalSensor(),
            ],
            40,
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([alt], MouseL, lazy.window.set_position_floating(),
        start=lazy.window.get_position()),
    Drag([alt], MouseR, lazy.window.set_size_floating(),
        start=lazy.window.get_size()),
    Click([alt], MouseM, lazy.window.bring_to_front())
]

wmname = "LG3D"

dgroups_key_binder = None
dgroups_app_rules = []
main = None
follow_mouse_focus = True
bring_front_click = True
cursor_warp = True
auto_fullscreen = False



@hook.subscribe.client_focus
def raiser(w):
  """Raise on focus."""
  w.cmd_bring_to_front()


@hook.subscribe.client_managed
def position(window):
  if window.maximized:
    return
  group = window.group
  screen = group.screen
  x, y = maxx, maxy = 0, 0

  for w in group.windows:
    if w.maximized:
      continue
    maxx = max(maxx, w.x)
    maxy = max(maxy, w.y)

  if (maxx or maxy) or len(group.windows)>1:
    x, y = maxx+50, maxy+50
  if x+window.width > 1920: #TODO screen.width:
    x = 100
  if y+window.height > 1080: #screen.height:
    y = 100

  window.tweak_float(x, y)


floating_layout = layout.Floating(auto_float_types=[
"notification",
"toolbar",
"splash",
"dialog",
])
