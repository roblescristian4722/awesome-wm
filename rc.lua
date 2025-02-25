-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- vicious
local vicious = require("vicious")

-- other widgets
local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local logout_menu_widget = require("awesome-wm-widgets.logout-menu-widget.logout-menu")
local lain = require("lain")
local calendar = require("calendar")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Autorun programs
autorun = true
autorunApps = 
{
    "nm-applet",
    "/usr/lib/polkit-kde-authentication-agent-1",
    "setxkbmap -layout latam",
    "xinput set-prop \"SynPS/2 Synaptics TouchPad\" \"libinput Tapping Enabled\" 1",
    "xinput set-prop \"SynPS/2 Synaptics TouchPad\" \"libinput Natural Scrolling Enabled\" 1",
    "pulseaudio -D",
    "picom -b"
}
if autorun then
   for app = 1, #autorunApps do
       awful.util.spawn(autorunApps[app])
   end
end

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.wallpaper = "/mnt/HDD/Wallpapers/874022.jpg"
beautiful.font = "FontAwesome 9"
naughty.config.defaults['icon_size'] = 50
-- beautiful.useless_gap = 5;

-- This is used later as the default terminal and editor to run.
terminal = "gnome-terminal"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    -- awful.layout.suit.floating,
    -- awful.layout.suit.magnifier,
    --awful.layout.suit.max,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.corner.nw,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- PulseAudio volume (based on multicolor theme)
local volume = lain.widget.pulse {
    timeout = 1,
    settings = function()
        vlevel = "Vol: " .. volume_now.channel[1] .. "% | " .. volume_now.device
        if volume_now.muted == "yes" then
            vlevel = vlevel .. " Muted"
        end
        widget:set_markup(lain.util.markup("#33A5FF", vlevel))
    end
}

-- Lain Battery
local batwidget = lain.widget.bat({
    batteries = { "BAT0" },
    timeout = 5,
    settings = function()
        vlevel = "Battery: " .. bat_now.perc .. "% " .. bat_now.status .. " "
        widget:set_markup(lain.util.markup("#33A5FF", vlevel))
    end
})

-- Clock
mytextclock = wibox.widget {
    format = "%A %d/%b/%y, %H:%M",
    widget = wibox.widget.textclock
}
-- attach it as popup to your text clock widget:
calendar({}):attach(mytextclock)

-- Memory Widget (vicious)
memwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.mem)
vicious.register(memwidget, vicious.widgets.mem, "Memory: $1% ($2MiB/$3MiB)", 15)

-- cpu usage (vicious)
cpuwidget = awful.widget.graph()
cpuwidget:set_width(50)
cpuwidget:set_background_color"#494B4F"
cpuwidget:set_color{ type = "linear", from = { 0, 0 }, to = { 50, 0 },
                     stops = { { 0, "#FF5656" },
                               { 0.5, "#88A175" },
                               { 1, "#AECF96" } } }
vicious.register(cpuwidget, vicious.widgets.cpu, "$1", 3)

-- net (vicious)
netwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.net)
vicious.register(netwidget, vicious.widgets.net, "enp4s0 ${enp4s0 down_kb}kb ↓ ${enp4s0 up_kb}kb ↑", 3)

-- Separator
separator = wibox.widget {
    widget = wibox.widget.separator,
    orientation = "vertical",
    opacity = 0.9,
    forced_width = 10
}

-- playerctl
player_widget = awful.widget.watch("playerctl metadata --format 'now playing: {{ artist }} - {{ title }}'", 3,
    function(widget, stdout)
	    widget:set_markup(stdout:gsub("\n", ""))
    	widget.align = "center"
    end)

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
            s.mytasklist,
         -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            separator,
            netwidget,
            separator,
            memwidget,
            separator,
            cpu_widget({
                    color = '#33A5FF',
                    enable_kill_button = true,
                    process_info_max_length = 80
                }),
            separator,
            player_widget,
            separator,
            volume,
            separator,
            mytextclock,
            separator,
            mykeyboardlayout,
            wibox.widget.systray(),
            logout_menu_widget(),
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    -- awful.button({ }, 4, awful.tag.viewnext),
    -- awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous keys", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next keys", group = "tag"}),
    awful.key({ modkey,           }, "k",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Tab",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "l",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
   
    -- Change PulseAudio default output
    awful.key({modkey}, ",", function() awful.util.spawn("pactl set-default-sink alsa_output.pci-0000_09_00.3.analog-stereo") end),
    awful.key({modkey}, ".", function() awful.util.spawn("pactl set-default-sink alsa_output.pci-0000_07_00.1.hdmi-stereo-extra1") end),
    
    -- Sepctacle
    awful.key({}, "Print", function() awful.util.spawn("spectacle") end),
    awful.key({"Control"}, "Print", function() awful.util.spawn("spectacle -c -b -f") end),
    awful.key({"Control", "Shift"}, "Print", function() awful.util.spawn("spectacle -c -b -r") end),

    -- nautilus
    awful.key({modkey}, "e", function() awful.util.spawn("nautilus") end),
    
    awful.key({ "Mod1", "Shift" }, "Tab", function () awful.client.focus.byidx(-1) end,
    {description = "focus prev by index", group = "client"}),
    awful.key({ "Mod1", }, "Tab", function () awful.client.focus.byidx(1) end,
    {description = "focus next by index", group = "client"}),
    awful.key({ "Mod1", }, "l", function () awful.client.focus.byidx( 1) end,
    {description = "focus next by index", group = "client"}),
    awful.key({ "Mod1", }, "k", function () awful.client.focus.byidx(-1) end,
    {description = "focus previous by index", group = "client"}),
    awful.key({ "Mod1",           }, "w", function () mymainmenu:show() end,
    {description = "show main menu", group = "awesome"}),

    -- modkey+Shift+Left/Right: move client to prev/next tag
    awful.key({ modkey, "Shift" }, "k",
        function ()
            -- get current tag
            local t = client.focus and client.focus.first_tag or nil
            if t == nil then
                return
            end
            -- get previous tag (modulo 9 excluding 0 to wrap from 1 to 9)
            local tag = client.focus.screen.tags[(t.name - 2) % 9 + 1]
            awful.client.movetotag(tag)
        end,
            {description = "move client to previous tag", group = "layout"}),
    awful.key({ modkey, "Shift" }, "l",
        function ()
            -- get current tag
            local t = client.focus and client.focus.first_tag or nil
            if t == nil then
                return
            end
            -- get next tag (modulo 9 excluding 0 to wrap from 9 to 1)
            local tag = client.focus.screen.tags[(t.name % 9) + 1]
            awful.client.movetotag(tag)
        end,
            {description = "move client to next tag", group = "layout"}),


    -- modkey+Shift+Left/Right: move client to prev/next tag
    awful.key({ modkey, "Shift" }, "Left",
        function ()
            -- get current tag
            local t = client.focus and client.focus.first_tag or nil
            if t == nil then
                return
            end
            -- get previous tag (modulo 9 excluding 0 to wrap from 1 to 9)
            local tag = client.focus.screen.tags[(t.name - 2) % 9 + 1]
            awful.client.movetotag(tag)
        end,
            {description = "move client to previous tag", group = "layout"}),
    awful.key({ modkey, "Shift" }, "Right",
        function ()
            -- get current tag
            local t = client.focus and client.focus.first_tag or nil
            if t == nil then
                return
            end
            -- get next tag (modulo 9 excluding 0 to wrap from 9 to 1)
            local tag = client.focus.screen.tags[(t.name % 9) + 1]
            awful.client.movetotag(tag)
        end,
            {description = "move client to next tag", group = "layout"}),

    -- Screen Lock
    awful.key({ "Control", "Shift" }, "l", function () awful.spawn("i3lock -t -i /mnt/HDD/Wallpapers/blade_runner_lock.png") end),
    -- Layout manipulation
    awful.key({ "Mod1", "Shift"   }, "l", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ "Mod1", "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "l", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ "Mod1",           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ "Mod1",           }, "Escape",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ "Mod1",           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ "Mod1",           }, "ñ",     function () awful.tag.incmwfact( 0.01)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ "Mod1",           }, "j",     function () awful.tag.incmwfact(-0.01)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ "Mod1", "Shift"   }, "j",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ "Mod1", "Shift"   }, "ñ",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ "Mod1", "Control" }, "j",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ "Mod1", "Control" }, "ñ",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ "Mod1",           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Mutiedia Keys
       awful.key({ }, "XF86AudioPause", function () awful.util.spawn("playerctl play-pause") end),
       awful.key({ }, "XF86AudioPlay", function () awful.util.spawn("playerctl play-pause") end),
    awful.key({ }, "XF86AudioNext", function () awful.util.spawn("playerctl next") end),
    awful.key({ }, "XF86AudioPrev", function () awful.util.spawn("playerctl previous") end),
    awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%") end),
    awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%") end),
     awful.key({ }, "XF86AudioMute", function () awful.util.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle") end),
     awful.key({ }, "XF86AudioMicMute", function () awful.util.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle") end),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "space", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ "Mod1",   }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
