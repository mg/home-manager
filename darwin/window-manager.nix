{lib, pkgs, machineConfig, ...}: let
  aerospace = "${pkgs.aerospace}/bin/aerospace";
  sketchybar = "${pkgs.sketchybar}/bin/sketchybar";
  appIconMap = "${pkgs.sketchybar-app-font}/bin/icon_map.sh";
  lua = pkgs.lua5_5.withPackages (_: [pkgs.sbarlua]);
  mainWorkspaces = map toString (lib.range 1 8);
  secondaryWorkspaces = ["9" "0"];
  workspaces = mainWorkspaces ++ secondaryWorkspaces;
  wallpaperDirectory = "${machineConfig.home}/Pictures/wallpapers";
  wallpaperStateDirectory = "${machineConfig.home}/Library/Application Support/AeroSpace/wallpapers";
  wallpaperCommand = "${machineConfig.home}/.local/bin/aerospace-wallpapers";

  setWallpaper = pkgs.writeText "set-aerospace-wallpaper.applescript" ''
    on run argv
      set wallpaperPath to item 1 of argv
      tell application "System Events"
        repeat with desktopItem in desktops
          set picture of desktopItem to wallpaperPath
        end repeat
      end tell
    end run
  '';

  wallpaperManager = pkgs.writeShellScript "aerospace-wallpapers" ''
    set -euo pipefail

    wallpaper_directory=${lib.escapeShellArg wallpaperDirectory}
    state_directory=${lib.escapeShellArg wallpaperStateDirectory}
    current_assignment="$state_directory/current"
    /bin/mkdir -p "$state_directory"

    wallpapers=()
    while IFS= read -r -d "" wallpaper; do
      wallpapers+=("$wallpaper")
    done < <(
      /usr/bin/find "$wallpaper_directory" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
           -o -iname '*.heic' -o -iname '*.webp' \) -print0 2>/dev/null
    )

    [ "''${#wallpapers[@]}" -gt 0 ] || exit 0

    previous=""
    if [ -f "$current_assignment" ]; then
      IFS= read -r previous < "$current_assignment" || true
    fi

    wallpaper="$previous"
    if [ "''${#wallpapers[@]}" -eq 1 ]; then
      wallpaper="''${wallpapers[0]}"
    else
      while [ "$wallpaper" = "$previous" ]; do
        wallpaper="''${wallpapers[RANDOM % ''${#wallpapers[@]}]}"
      done
    fi

    if /usr/bin/osascript ${setWallpaper} "$wallpaper"; then
      printf '%s\n' "$wallpaper" > "$current_assignment.tmp"
      /bin/mv "$current_assignment.tmp" "$current_assignment"
    fi
  '';

  placeGhostty = pkgs.writeShellScript "aerospace-place-ghostty" ''
    # Give AeroSpace time to update its monitor list after a display event.
    if [ "''${1:-}" = all ]; then
      /bin/sleep 1
    fi

    monitors="$(${aerospace} list-monitors --format '%{monitor-name}')"
    if /usr/bin/grep -Fq "OLED55CX6LA" <<< "$monitors"; then
      # SketchyBar's display_change also fires when the focused display changes,
      # not only when displays are connected. Do not let it undo manual moves.
      [ "''${1:-}" = all ] && exit 0
      workspace=3
    elif [ "$(${aerospace} list-monitors --count)" -gt 1 ]; then
      workspace=9
    else
      workspace=3
    fi

    if [ "''${1:-}" = all ]; then
      ${aerospace} list-windows --all --format '%{window-id}|%{app-bundle-id}' |
        while IFS='|' read -r window_id app_id; do
          if [ "$app_id" = com.mitchellh.ghostty ]; then
            ${aerospace} move-node-to-workspace --window-id "$window_id" "$workspace"
          fi
        done
    else
      window_id="''${AEROSPACE_WINDOW_ID:-}"
      [ -n "$window_id" ] || exit 0
      ${aerospace} move-node-to-workspace --window-id "$window_id" "$workspace"
    fi
  '';

  networkStatus = pkgs.writeShellScript "sketchybar-network-status" ''
    wifi_device=$(/usr/sbin/networksetup -listallhardwareports | /usr/bin/awk '
      /Hardware Port: (Wi-Fi|AirPort)/ { getline; sub(/^Device: /, ""); print; exit }
    ')
    route_device=$(/sbin/route -n get default 2>/dev/null | /usr/bin/awk '/interface:/ { print $2; exit }')

    if [ -z "$route_device" ]; then
      printf 'Offline\n'
    elif [[ "$route_device" == utun* ]]; then
      printf 'VPN\n'
    elif [ -n "$wifi_device" ] && [ "$route_device" = "$wifi_device" ]; then
      printf 'Wi-Fi\n'
    elif [[ "$route_device" == en* ]]; then
      printf 'Ethernet\n'
    else
      printf 'Network\n'
    fi
  '';
in {
  # SketchyBar replaces the always-visible menu bar; macOS menus remain
  # accessible by moving the pointer to the top of the screen.
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;

  services.aerospace = {
    enable = true;
    settings = {
      # Both services are started by nix-darwin's launchd agents.
      start-at-login = false;
      config-version = 2;
      persistent-workspaces = workspaces;
      workspace-to-monitor-force-assignment =
        lib.listToAttrs (map (workspace:
          lib.nameValuePair workspace "built-in"
        ) mainWorkspaces)
        // lib.listToAttrs (map (workspace:
          lib.nameValuePair workspace "secondary"
        ) secondaryWorkspaces);
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";
      on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];

      exec-on-workspace-change = [
        "/bin/bash"
        "-c"
        ''${sketchybar} --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$AEROSPACE_FOCUSED_WORKSPACE"''
      ];

      gaps = {
        inner.horizontal = 0;
        inner.vertical = 0;
        outer.left = 0;
        outer.right = 0;
        outer.bottom = 0;
        # The built-in display already reserves its camera-cutout area. Every
        # external display uses the fallback gap so SketchyBar never covers app
        # windows, regardless of the monitor's name.
        outer.top = [
          {monitor."Built-in Retina Display" = 0;}
          32
        ];
      };

      # AeroSpace calls the macOS Command (Super) modifier `cmd`.
      mode.main.binding = {
        cmd-shift-h = "focus left";
        cmd-shift-j = "focus down";
        cmd-shift-k = "focus up";
        cmd-shift-l = "focus right";
        cmd-alt-h = "move left";
        cmd-alt-j = "move down";
        cmd-alt-k = "move up";
        cmd-alt-l = "move right";
        cmd-alt-minus = "resize smart -50";
        cmd-alt-equal = "resize smart +50";
        cmd-slash = "layout tiles horizontal vertical";
        cmd-comma = "layout accordion horizontal vertical";
        cmd-shift-space = "layout floating tiling";
        cmd-f = "fullscreen";
        cmd-alt-tab = "workspace-back-and-forth";
        cmd-alt-w = "exec-and-forget ${wallpaperCommand}";
        cmd-shift-tab = "move-workspace-to-monitor --wrap-around next";
      } // lib.listToAttrs (lib.concatMap (workspace: [
        (lib.nameValuePair "cmd-${workspace}" "workspace ${workspace}")
        (lib.nameValuePair "cmd-alt-${workspace}" "move-node-to-workspace ${workspace}")
      ]) workspaces);

      on-window-detected = [
        {
          "if".app-id = "com.apple.systempreferences";
          run = "layout floating";
        }
        {
          "if".app-id = "com.mitchellh.ghostty";
          run = "exec-and-forget ${placeGhostty}";
        }
        {
          "if".app-id = "md.obsidian";
          run = "move-node-to-workspace 2";
        }
        {
          "if".app-id = "com.ranchero.NetNewsWire-Evergreen";
          run = "move-node-to-workspace 8";
        }
      ];
    };
  };

  # Keep the executable path stable so macOS Background Items does not expose
  # a new Nix store hash after every script change.
  system.activationScripts.extraActivation.text = lib.mkAfter ''
    install_directory=${lib.escapeShellArg "${machineConfig.home}/.local/bin"}
    install_target=${lib.escapeShellArg wallpaperCommand}
    /usr/bin/install -d -m 0755 -o ${machineConfig.username} -g staff "$install_directory"
    /usr/bin/install -m 0755 ${wallpaperManager} "$install_target.new"
    /usr/sbin/chown ${machineConfig.username}:staff "$install_target.new"
    /bin/mv -f "$install_target.new" "$install_target"
  '';

  services.sketchybar = {
    enable = true;
    extraPackages = [lua pkgs.sketchybar-app-font];
    config = ''
      #!${lua}/bin/lua
      local sbar = require("sketchybar")

      local aerospace = "${aerospace}"
      local app_icon_map = "${appIconMap}"
      local network_status = "${networkStatus}"
      local active_color = 0xff1e1e2e
      local text_color = 0xffcdd6f4
      local accent_color = 0xff89b4fa
      local icons = {
        volume = {
          high = "󰕾",
          medium = "󰕿",
          low = "󰖀",
          quiet = "󰖀",
          muted = "󰖁",
        },
        battery = {
          full = "󰁹",
          high = "󰂁",
          medium = "󰁾",
          low = "󰁻",
          empty = "󰂃",
          charging = "󰂄",
        },
      }

      local function app_font()
        return {
          family = "sketchybar-app-font",
          style = "Regular",
          size = 14.0,
          features = "liga",
        }
      end

      local function shell_quote(value)
        local quote = string.char(39)
        local escaped_quote = quote .. "\\" .. quote .. quote
        return quote .. tostring(value):gsub(quote, escaped_quote) .. quote
      end

      local function trim(value)
        return (tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", ""))
      end

      local function map_icons(apps, callback)
        if #apps == 0 then
          callback("")
          return
        end

        local args = {}
        for _, app in ipairs(apps) do
          table.insert(args, shell_quote(app))
        end
        sbar.exec(app_icon_map .. " " .. table.concat(args, " "), function(result)
          callback(trim(result))
        end)
      end

      sbar.begin_config()

      sbar.bar({
        position = "top",
        height = 32,
        -- Only the built-in Retina display gets a slightly taller bar.
        notch_display_height = 38,
        display = "all",
        topmost = "window",
        color = active_color,
        padding_left = 8,
        padding_right = 8,
      })

      sbar.default({
        icon = { drawing = false },
        label = {
          font = "SF Pro:Medium:13.0",
          color = text_color,
          padding_left = 8,
          padding_right = 8,
        },
        padding_left = 2,
        padding_right = 2,
        background = {
          color = accent_color,
          corner_radius = 5,
          height = 24,
          drawing = false,
        },
      })

      sbar.add("event", "aerospace_workspace_change")

      local workspace_names = {${lib.concatMapStringsSep ", " (workspace: ''"${workspace}"'') workspaces}}
      local workspace_items = {}
      for _, workspace in ipairs(workspace_names) do
        local secondary = workspace == "9" or workspace == "0"
        local item = sbar.add("item", "workspace." .. workspace, {
          position = "left",
          display = secondary and 2 or 1,
          icon = {
            drawing = true,
            string = workspace,
            font = "SF Pro:Semibold:13.0",
            color = text_color,
            padding_left = 8,
            padding_right = 4,
          },
          label = {
            string = "",
            font = app_font(),
            color = text_color,
            padding_left = 2,
            padding_right = 8,
          },
        })
        workspace_items[workspace] = item
        item:subscribe("mouse.clicked", function()
          sbar.exec(aerospace .. " workspace " .. workspace)
        end)
      end

      local workspace_generation = 0
      local function update_workspaces(env)
        workspace_generation = workspace_generation + 1
        local generation = workspace_generation
        local function apply_visible(result)
          if generation ~= workspace_generation then return end
          local visible = {}
          for workspace in tostring(result or ""):gmatch("[^\r\n]+") do
            visible[trim(workspace)] = true
          end
          for _, workspace in ipairs(workspace_names) do
            local item = workspace_items[workspace]
            local selected = visible[workspace] == true
            item:set({
              icon = { color = selected and active_color or text_color },
              label = { color = selected and active_color or text_color },
              background = { drawing = selected },
            })
          end
        end

        sbar.exec(
          aerospace .. " list-workspaces --monitor all --visible --format '%{workspace}'",
          apply_visible
        )

        for _, workspace in ipairs(workspace_names) do
          local item = workspace_items[workspace]
          local command = aerospace
            .. " list-windows --workspace " .. workspace
            .. " --format '%{app-name}'"
          sbar.exec(command, function(result)
            local apps, seen = {}, {}
            for app in tostring(result or ""):gmatch("[^\r\n]+") do
              local normalized_app = trim(app)
              if normalized_app ~= "" and not seen[normalized_app] then
                seen[normalized_app] = true
                table.insert(apps, normalized_app)
              end
            end
            map_icons(apps, function(icons)
              if generation == workspace_generation then
                item:set({ label = { string = icons, drawing = icons ~= "" } })
              end
            end)
          end)
        end
      end

      workspace_items["1"]:set({ update_freq = 10 })
      workspace_items["1"]:subscribe(
        {"routine", "aerospace_workspace_change", "space_windows_change", "system_woke"},
        update_workspaces
      )
      workspace_items["1"]:subscribe("display_change", function()
        sbar.exec("${placeGhostty} all")
        update_workspaces()
      end)

      local front_app = sbar.add("item", "front_app", {
        position = "left",
        update_freq = 10,
        background = { drawing = false },
        icon = {
          drawing = true,
          font = app_font(),
          padding_left = 8,
          padding_right = 2,
        },
        label = { max_chars = 28 },
      })

      local front_app_generation = 0
      local function set_front_app(app, generation)
        if generation ~= front_app_generation then return end
        app = trim(app)
        if app == "" then
          front_app:set({ drawing = false })
          return
        end
        map_icons({app}, function(icon)
          if generation == front_app_generation then
            front_app:set({
              drawing = true,
              icon = { string = icon },
              label = { string = app },
            })
          end
        end)
      end

      local function update_front_app(env)
        front_app_generation = front_app_generation + 1
        local generation = front_app_generation
        if env and env.INFO and env.INFO ~= "" and env.SENDER == "front_app_switched" then
          set_front_app(env.INFO, generation)
        else
          sbar.exec(aerospace .. " list-windows --focused --format '%{app-name}'", function(app)
            set_front_app(app, generation)
          end)
        end
      end
      front_app:subscribe({"routine", "front_app_switched", "system_woke"}, update_front_app)

      local volume = sbar.add("item", "volume", {
        position = "right",
        update_freq = 60,
        background = { drawing = false },
        icon = {
          drawing = true,
          string = icons.volume.high,
          font = "FiraCode Nerd Font:Regular:15.0",
        },
      })
      local function update_volume()
        sbar.exec(
          "/usr/bin/osascript -e 'get {output volume, output muted} of (get volume settings)'",
          function(result)
            local level, muted = tostring(result or ""):match("(%d+),%s*(%a+)")
            if not level then return end
            local numeric_level = tonumber(level)
            local is_muted = muted == "true" or numeric_level == 0
            local icon = icons.volume.muted
            if not is_muted and numeric_level > 60 then
              icon = icons.volume.high
            elseif not is_muted and numeric_level > 30 then
              icon = icons.volume.medium
            elseif not is_muted and numeric_level > 10 then
              icon = icons.volume.low
            elseif not is_muted then
              icon = icons.volume.quiet
            end
            volume:set({
              icon = { string = icon },
              label = { string = is_muted and "MUTE" or (level .. "%") },
            })
          end
        )
      end
      volume:subscribe({"routine", "volume_change", "system_woke"}, update_volume)
      volume:subscribe("mouse.clicked", function()
        sbar.exec(
          "/usr/bin/osascript -e 'set volume output muted not (output muted of (get volume settings))'",
          update_volume
        )
      end)

      local network = sbar.add("item", "network", {
        position = "right",
        update_freq = 60,
        background = { drawing = false },
        icon = {
          drawing = true,
          string = ":wifi:",
          font = app_font(),
        },
      })
      local function update_network()
        sbar.exec(network_status, function(result)
          network:set({ label = { string = trim(result) } })
        end)
      end
      network:subscribe({"routine", "wifi_change", "system_woke"}, update_network)

      local battery = sbar.add("item", "battery", {
        position = "right",
        update_freq = 120,
        background = { drawing = false },
        icon = {
          drawing = true,
          string = icons.battery.full,
          font = "FiraCode Nerd Font:Regular:17.0",
        },
      })
      local function update_battery()
        sbar.exec("/usr/bin/pmset -g batt", function(result)
          local charge = tostring(result or ""):match("(%d+)%%")
          if not charge then
            battery:set({ drawing = false })
            return
          end
          local numeric_charge = tonumber(charge)
          local charging = tostring(result):find("AC Power", 1, true) ~= nil
          local icon = icons.battery.empty
          if charging then
            icon = icons.battery.charging
          elseif numeric_charge > 80 then
            icon = icons.battery.full
          elseif numeric_charge > 60 then
            icon = icons.battery.high
          elseif numeric_charge > 40 then
            icon = icons.battery.medium
          elseif numeric_charge > 20 then
            icon = icons.battery.low
          end
          battery:set({
            drawing = true,
            icon = { string = icon },
            label = {
              string = charge .. "%",
              color = tonumber(charge) <= 15 and 0xfff38ba8 or text_color,
            },
          })
        end)
      end
      battery:subscribe({"routine", "power_source_change", "system_woke"}, update_battery)

      local clock = sbar.add("item", "clock", {
        position = "right",
        update_freq = 10,
        background = { drawing = false },
      })
      local function update_clock()
        clock:set({ label = { string = os.date("%a %d %b  %H:%M") } })
      end
      clock:subscribe({"routine", "system_woke"}, update_clock)

      sbar.hotload(true)
      sbar.end_config()

      update_workspaces()
      update_front_app()
      update_volume()
      update_network()
      update_battery()
      update_clock()
      sbar.event_loop()
    '';
  };
}
