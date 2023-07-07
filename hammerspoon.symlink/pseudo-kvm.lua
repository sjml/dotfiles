-- Inspired by https://github.com/haimgel/display-switch, which
--   sadly does not work on Apple Silicon at the moment. :(
--   Makes use of a compiled version of https://github.com/waydabber/m1ddc
--   that is also in this repo (the bin.homelink that ends up symlinked to
--   ~/bin). I probably should have found another home for a compiled tool,
--   given that the rest of that directory are scripts, but this'll do.

local log = hs.logger.new("pseudo-kvm", "debug")

local DOCKING_STATION_VENDOR = 0x2188
local DOCKING_STATION_PRODUCT = 0x5500
local USB_SWITCH_VENDOR = 0x1a40
local USB_SWITCH_PRODUCT = 0x0101


-- look for the the docking station for my Mac
local function isDocked()
  for _, data in pairs(hs.usb.attachedDevices()) do
    if data["vendorID"] == DOCKING_STATION_VENDOR and data["productID"] == DOCKING_STATION_PRODUCT then
      return true
    end
  end
  return false
end

local function usbWatcherCallback(data)
  if not isDocked() then
    return
  end
  if data["vendorID"] == USB_SWITCH_VENDOR and data["productID"] == USB_SWITCH_PRODUCT then
    if data["eventType"] == "added" then
      -- change to DisplayPort 1 (input 15)
      local output, status, _type, rc = hs.execute("~/bin/m1ddc set input 15")
    elseif data["eventType"] == "removed" then
      -- change to HDMI 1 (input 17)
      local output, status, _type, rc = hs.execute("~/bin/m1ddc set input 17")
    end
  end
end

local usbWatcher = hs.usb.watcher.new(usbWatcherCallback)
usbWatcher:start()


-- macOS >= High Sierra gets finicky waking from sleep with USB watching active,
--   for some reason. Shut off watching when we're about to sleep and
--   turn it back on when we wake up.
local function toggleWatcher(eventType)
  if (eventType == hs.caffeinate.watcher.systemDidWake) then
      usbWatcher:start()
  elseif (eventType == hs.caffeinate.watcher.systemWillSleep) then
      usbWatcher:stop()
  end
end

local caffeinateWatcher = hs.caffeinate.watcher.new(toggleWatcher)
caffeinateWatcher:start()
