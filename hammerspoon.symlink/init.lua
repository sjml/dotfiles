-- Note: if Hammerspoon's menubar and dock icons are hidden,
--   get back to the preferences screen by activating the
--   console from Spotlight and hitting Command-Comma.

function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
local configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()


hyper = {"ctrl", "alt", "cmd"}
hypershift = {"ctrl", "alt", "cmd", "shift"}

require('position')
require('move-window')
require('mute-on-unlock')
require('pseudo-kvm')
require('monitor-standby')
-- require('DISABLED_drive-handler')

local initialAlertStyle = {
  fillColor = {white = 1, alpha = 0.9},
  textColor = {black = 1},
  strokeColor = {black = 1},
  fadeInDuration = 1.0,
  fadeOutDuration = 1.0,
}
hs.alert.show("🔨 Hammerspoon Loaded 🥄", initialAlertStyle)
