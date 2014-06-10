-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
awful.completion = require("awful.completion")
--awful.client = require("awful.completion")
awful.completion.bashcomp_load()
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

local percent_to_change_backlight = '10'
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
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Custom functions

function table.val_to_str ( v )
    if "string" == type( v ) then
        v = string.gsub( v, "\n", "\\n" )
        if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
            return "'" .. v .. "'"
        end
        return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
    else
        return "table" == type( v ) and table.tostring( v ) or
        tostring( v )
    end
end

function table.key_to_str ( k )
    if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
        return k
    else
        return "[" .. table.val_to_str( k ) .. "]"
    end
end

function table.tostring( tbl )
    local result, done = {}, {}
    for k, v in ipairs( tbl ) do
        table.insert( result, table.val_to_str( v ) )
        done[ k ] = true
    end
    for k, v in pairs( tbl ) do
        if not done[ k ] then
            table.insert( result,
            table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
        end
    end
    return "{" .. table.concat( result, "," ) .. "}"
end

--TODO check to see if display is already ok
function change_screenlayout()
    local connections = os.popen("xrandr | grep ' connected ' | cut -d ' ' -f 1")
    for connection in connections:lines() do
        if connection == "VGA1" then
            os.execute("xrandr --output HDMI1 --off --output LVDS1 --mode 1366x768 --pos 0x0 --rotate normal --output VIRTUAL1 --off --output DP1 --off --output VGA1 --mode 1920x1080 --pos 1366x0 --rotate normal")
        elseif connection == "HDMI1" then
           --TODO
        elseif connection == "DP1" then
           --TODO
        elseif connection == "VIRTUAL1" then
           --TODO
        else
            display_critical_text("Unknown video connection "..connection.."!")
        end
    end
end

function connect_to_wifi(profile, interface)
    interface = interface or 'wlp2s0'
    os.execute("sudo netctl stop-all")
    os.execute("sudo ip link set "..interface.." down")
    local start_res =os.execute("sudo netctl start "..profile)

    if start_res then
        naughty.notify{
            text = 'Connected succesfully.',
            preset = naughty.config.presets.normal,
            timeout = 5
        }
    else
    --TODO get error message
        naughty.notify{
            text = 'A problem occured while trying to connect.',
            preset = naughty.config.presets.critical,
            timeout = 5
        }
    end

end

function display_text(text, title)
    naughty.notify({ preset = naughty.config.presets.normal,
    title = title,
    text = text })
end

function display_critical_text(text, title)
    naughty.notify({ preset = naughty.config.presets.critical,
    title = title,
    text = text })
end

function shift_to_tag(shift_amount, switch)
    if not client then
        return
    end
    local current_client = client.focus
    local client_tags = current_client:tags()
    local tag_index = -1
    --local tag_to_use = nil
    local tags = awful.tag.gettags(client.focus.screen)

    for _,client_tag in ipairs(client_tags) do
        for i,tag in ipairs(tags) do
            if tag == client_tag then
                tag_index = i
                --tag_to_use
                break
            end
        end
        if tag_index > -1 then
            break
        end
    end
    if tag_index <= -1 then
        display_text("Couldn't find a valid tag.'", "Don't panic")
        return
    end
    local new_tag_idx = tag_index + shift_amount
    if new_tag_idx > #tags then
        new_tag_idx = new_tag_idx - #tags
    elseif new_tag_idx < 1 then
        new_tag_idx = new_tag_idx + #tags
    end

    local tag = tags[new_tag_idx];
    awful.client.movetotag(tag)
    if switch then
        awful.tag.viewonly(tag)
    end
    --TODO make sure the client is still focused
end

function toggle_touchpad()
    local pout = io.popen('synclient -l | grep TouchpadOff')
    local res = pout:read()
    pout.close()

    local _, idx = res:find("= ")
    local status = res:sub(idx+1)
    if status == '0' then
        os.execute('synclient TouchpadOff=1')
    else
        os.execute('synclient TouchpadOff=0')
    end

end

function toggle_wireless()
    local out = io.popen('rfkill list')
    local pattern = '%s+'..'Soft blocked: (%a+)'
    for line  in out:lines()  do
        local match = line:match(pattern)
        display_text(line)
        --if match then display_text(line)  end
--        if match and match == 'no' then
--            os.execute('sudo rfkill block all')
--            out:close()
--            return
--        end
    end
    out:close()
    --os.execute('sudo rfkill unblock all')
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
-- terminal = "xterm -e tmux"
terminal = os.getenv("TERM") or "xterm"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
    for i, _tag in ipairs(tags[s]) do
            _tag:connect_signal("property::selected", function(tag)
                if tag.selected then
                    local clients = tag:clients()
                    if #clients <= 1 then return end
                    for j,c in ipairs(clients) do
                        local succeeded, idx = pcall(awful.client.idx, c)
                        if succeeded and idx.col ==0 then
                            --TODO focus
                            awful.client.focus.byidx(0, c)
                        end
                    end
                end
            end)
    end
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
    --TODO
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

leavemenu ={
   { "shutdown", "sudo shutdown -h now" },
   { "reboot", "sudo reboot" },
   { "suspend", "sudo pm-suspend" },
   { "exit", awesome.quit },
}

wifi_menu={
    {'home', function() connect_to_wifi('home') end},
    {'work', function() connect_to_wifi('work') end},
}

function start_work()
  os.execute("xrandr --ouput HDMI1 --off --output LVDS1 --mode 1366x768 --pos 0x0 --rotate normal --output VIRTUAL1 --off --output DP1 --off --output VGA1 --mode 1920x1080 --pos 1366x0 --rotate normal")
  connect_to_wifi('work')

  local lscreen = 1;
  local rscreen = screen.count()

  local cwork_pid = awful.util.spawn(
    "google-chrome-stable --profile-directory=Work",
    true,
    lscreen)

  local ctest_pid = awful.util.spawn(
    "google-chrome-stable --profile-directory=Cloudisnow",
    true,
    lscreen)

  local cfun_pid = awful.util.spawn(
    "google-chrome-stable --profile-directory=Default",
    true,
    lscreen)

  local kate_pid = awful.util.spawn(
    "kate -s NM",
--     "emacs -Q",
    true,
    rscreen)

  local konsole_pid = awful.util.spawn(
   terminal..' -e tmux',
    true,
    lscreen)

    local cwork_rule = {rule = { pid = cwork_pid }, properties = {
        tag = tags[lscreen][1],
        maximized_horizontal = true,
        maximized_vertical = true,
    } }

    local ctest_rule = {rule = { pid = ctest_pid }, properties = {
        tag = tags[lscreen][1],
        maximized_horizontal = true,
        maximized_vertical = true,
    } }

    local cfun_rule = {rule = { pid = cfun_pid }, properties = {
        tag = tags[lscreen][2],
        maximized_horizontal = true,
        maximized_vertical = true,
    } }

    local kate_rule = {rule = { pid = kate_pid }, properties = {
        tag = tags[rscreen][1],
        maximized_horizontal = true,
        maximized_vertical = true,
    } }

    local konsole_rule = {rule = { pid = konsole_pid }, properties = {
        tag = tags[lscreen][1],
        maximized_horizontal = true,
        maximized_vertical = true,
    } }

    awful.rules.rules[#awful.rules.rules+1] = cwork_rule
    awful.rules.rules[#awful.rules.rules+1] = ctest_rule
    awful.rules.rules[#awful.rules.rules+1] = cfun_rule
    awful.rules.rules[#awful.rules.rules+1] = kate_rule
    awful.rules.rules[#awful.rules.rules+1] = konsole_rule

end

--[[
awesome.connect_signal("spawn::completed", function (event)
    display_text("spawn", event.id)
end)
--]]

function client_props()
    --local clients - client.get()
    local out = io.open('/home/bmcgloin/client_vals')
end

--[[
function test_func()
    local client_items = client.get()
    local f = io.open('/home/bmcgloin/client_vals', 'w')
    for idx, value in ipairs(client_items) do
        f:write('window: '..tostring(value.window)..'\n')
        f:write('name: '..tostring(value.name)..'\n')
        f:write('skip_taskbar: '..tostring(value.skip_taskbar)..'\n')
        f:write('type: '..tostring(value.type)..'\n')
        f:write('class: '..tostring(value.class)..'\n')
        f:write('instance: '..tostring(value.instance)..'\n')
        f:write('pid: '..tostring(value.pid)..'\n')
        f:write('role: '..tostring(value.role)..'\n')
        f:write('machine: '..tostring(value.machine)..'\n')
        f:write('icon_name: '..tostring(value.icon_name)..'\n')
        f:write('icon: '..tostring(value.icon)..'\n')
        f:write('screen: '..tostring(value.screen)..'\n')
        f:write('hidden: '..tostring(value.hidden)..'\n')
        f:write('minimized: '..tostring(value.minimized)..'\n')
        f:write('size_hints_honor: '..tostring(value.size_hints_honor)..'\n')
        f:write('border_width: '..tostring(value.border_width)..'\n')
        f:write('border_color: '..tostring(value.border_color)..'\n')
        f:write('urgent: '..tostring(value.urgent)..'\n')
--         f:write('content: '..type(value.content)..'\n')
        f:write('focus: '..tostring(value.focus)..'\n')
        f:write('opacity: '..tostring(value.opacity)..'\n')
        f:write('ontop: '..tostring(value.ontop)..'\n')
        f:write('above: '..tostring(value.above)..'\n')
        f:write('below: '..tostring(value.below)..'\n')
        f:write('fullscreen: '..tostring(value.fullscreen)..'\n')
        f:write('maximized_horizontal: '..tostring(value.maximized_horizontal)..'\n')
        f:write('maximized_vertical: '..tostring(value.maximized_vertical)..'\n')
        f:write('transient_for: '..tostring(value.transient_for)..'\n')
        f:write('group_window: '..tostring(value.group_window)..'\n')
        f:write('leader_window: '..tostring(value.leader_window)..'\n')
        f:write('size_hints: '..tostring(value.size_hints)..'\n')
        f:write('sticky: '..tostring(value.sticky)..'\n')
        f:write('modal: '..tostring(value.modal)..'\n')
        f:write('focusable: '..tostring(value.focusable)..'\n')
        f:write('shape_bounding: '..tostring(value.shape_bounding)..'\n')
        f:write('shape_clip: '..tostring(value.shape_clip)..'\n')
        f:write('tags:\n')
        for idx, tag in ipairs(value:tags()) do
            f:write('\t'..tostring(tag)..'\n')
        end
        f:write('\n=======================================================\n')
    end
    f:close()
    display_text("done", "done")
end

function test_func2()
--     local sr = ''
    display_text(nil, tostring(#awful.rules.rules))
end

--]]
mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { 'connect to', wifi_menu},
                                    { "stage left", leavemenu },
                                    --{ "start work", start_work },
--                                     { "test", test_func},
--                                     { "test2", test_func2},
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal ..' -e tmux' -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)
--     right_layout:add(obvious.battery())

    --TODO

    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(

    awful.key({}, "XF86WLAN", toggle_wireless),
    awful.key({}, "XF86AudioLowerVolume", function() os.execute('pulseaudio-ctl down') end),
    awful.key({}, "XF86AudioRaiseVolume", function() os.execute('pulseaudio-ctl up') end),
    awful.key({}, "XF86AudioMute", function() os.execute('pulseaudio-ctl mute') end),
    awful.key({}, "XF86TouchpadToggle", toggle_touchpad),
    awful.key({}, "XF86MonBrightnessUp", function() os.execute('sudo light -qa '..percent_to_change_backlight) end),
    awful.key({}, "XF86MonBrightnessDown", function() os.execute('sudo light -qs '..percent_to_change_backlight) end),

    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation

    awful.key({ modkey, "Control", "Shift" }, "Up", function () awful.client.swap.bydirection('up')    end),
    awful.key({ modkey, "Control", "Shift" }, "Down", function () awful.client.swap.bydirection('down')    end),
    awful.key({ modkey, "Control", "Shift" }, "Right", function () awful.client.swap.bydirection('right')    end),
    awful.key({ modkey, "Control", "Shift" }, "Left", function () awful.client.swap.bydirection('left')    end),
    awful.key({ modkey, "Shift"   }, "Right", function () shift_to_tag(1, false) end),
    awful.key({ modkey, "Shift"   }, "Left", function () shift_to_tag(-1, false) end),
    --To prevent me from messing up when navigating tmux
    awful.key({ modkey, "Shift"   }, "Up", function() return end),
    awful.key({ modkey, "Shift"   }, "Down", function() return end),

    awful.key({ modkey, "Control" }, "Right", function () shift_to_tag(1, true) end),
    awful.key({ modkey, "Control" }, "Left", function () shift_to_tag(-1, true) end),
    --To prevent me from messing up when navigating tmux
    awful.key({ modkey, "Control" }, "Up", function() return end),
    awful.key({ modkey, "Control" }, "Down", function() return end),

    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    --TODO make spawn from current client?
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal..' -e tmux') end),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    --Custom bindings
    awful.key({ modkey,           }, "c", function () awful.util.spawn("google-chrome-stable") end),
    awful.key({ modkey,           }, "b", function () awful.util.spawn("luakit") end),
    awful.key({ modkey,           }, "e", function () awful.util.spawn_with_shell(editor) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules

awful.rules.rules[#awful.rules.rules+1]={
    rule = { },
    properties = {
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        keys = clientkeys,
        buttons = clientbuttons
    }
}

-- awful.rules.rules[#awful.rules.rules+1]= { rule = { class = "MPlayer" }, properties = { floating = true } }
-- awful.rules.rules[#awful.rules.rules+1]= { rule = { class = "pinentry" }, properties = { floating = true } }
-- awful.rules.rules[#awful.rules.rules+1]={ rule = { class = "gimp" }, properties = { floating = true } }


-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
