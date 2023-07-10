mute_on_unlock = {}
local util = require("util")
mute_on_unlock.log = hs.logger.new("mute-on-unlock", "debug")


local function muteOnUnlock(eventType)
  -- mute_on_unlock.log.i("mute-on-unlock watcher event")
  if util.isDocked() then
    return
  end
  -- mute_on_unlock.log.i("mute-on-unlock not docked")
  if (eventType == hs.caffeinate.watcher.screensDidUnlock) then
    -- mute_on_unlock.log.i("mute-on-unlock awake")
    local output = hs.audiodevice.defaultOutputDevice()
    output:setMuted(true)
    hs.alert.show("Audio Muted 🔇")
  end
end

mute_on_unlock.caffeinateWatcher = hs.caffeinate.watcher.new(muteOnUnlock)
mute_on_unlock.caffeinateWatcher:start()
