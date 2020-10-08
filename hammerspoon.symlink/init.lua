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
require('hub-handler')

hs.alert.show("Hammerspoon Loaded")
